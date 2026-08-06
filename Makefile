# ==========================================
# MAKEFILE - FLUTTER PROJECT AUTOMATION
# App: trilha_app/ (rode da raiz do monorepo ou via trilha_app/Makefile)
# ==========================================

APP := trilha_app

.PHONY: help clean get reset reset_hard \
        run run_release run_profile \
        apk aab build_apk build_aab \
        analyze test test_coverage \
        android_clean android_fix_gradle android_build deep_clean_android \
        ios_pods ios_update ios_clean ios_reset ios_run ios_build open_ios deep_clean_ios \
        doctor upgrade clean_cache fix_permissions

# ==========================================
# CORES
# ==========================================

GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# ==========================================
# FLUTTER BÁSICO
# ==========================================

clean:
	@echo "$(GREEN)🧹 Limpando projeto Flutter...$(NC)"
	cd $(APP) && flutter clean

get:
	@echo "$(GREEN)📦 Instalando dependências...$(NC)"
	cd $(APP) && flutter pub get

reset: clean get
	@echo "$(GREEN)✅ Projeto resetado$(NC)"

reset_hard: clean_cache clean get
	@echo "$(GREEN)🔥 Reset HARD concluído$(NC)"

# ==========================================
# EXECUÇÃO
# ==========================================

run:
	@echo "$(GREEN)🚀 Rodando app (debug)...$(NC)"
	cd $(APP) && flutter run

run_release:
	@echo "$(GREEN)🚀 Rodando app (release)...$(NC)"
	cd $(APP) && flutter run --release

run_profile:
	@echo "$(GREEN)📊 Rodando app (profile)...$(NC)"
	cd $(APP) && flutter run --profile

# ==========================================
# BUILD
# ==========================================

apk build_apk:
	@echo "$(GREEN)📱 Gerando APK release...$(NC)"
	cd $(APP) && flutter build apk --release

aab build_aab:
	@echo "$(GREEN)📦 Gerando AppBundle...$(NC)"
	cd $(APP) && flutter build appbundle

# ==========================================
# ANÁLISE E TESTES
# ==========================================

analyze:
	@echo "$(GREEN)🔍 Analisando código...$(NC)"
	cd $(APP) && flutter analyze

test:
	@echo "$(GREEN)🧪 Rodando testes...$(NC)"
	cd $(APP) && flutter test

test_coverage:
	@echo "$(GREEN)📊 Gerando cobertura de testes...$(NC)"
	cd $(APP) && flutter test --coverage
	cd $(APP) && genhtml coverage/lcov.info -o coverage/html
	open $(APP)/coverage/html/index.html

# ==========================================
# ANDROID
# ==========================================

android_clean:
	@echo "$(GREEN)🤖 Limpando build Android...$(NC)"
	rm -rf $(APP)/android/.gradle
	rm -rf $(APP)/android/build

# Corrige cache Gradle corrompido (metadata.bin / kotlin-dsl)
android_fix_gradle:
	@echo "$(GREEN)🔧 Corrigindo cache Gradle...$(NC)"
	cd $(APP)/android && ./gradlew --stop || true
	rm -rf $(HOME)/.gradle/caches/8.12/kotlin-dsl
	rm -rf $(APP)/android/.gradle
	@echo "$(GREEN)✅ Cache Gradle limpo. Rode: make run$(NC)"

android_build: apk

deep_clean_android:
	@echo "$(GREEN)🔥 Limpeza profunda Android...$(NC)"
	cd $(APP) && flutter clean
	rm -rf $(APP)/android/.gradle
	rm -rf $(APP)/android/build
	rm -rf ~/.gradle/caches
	rm -rf ~/.gradle/daemon
	rm -rf ~/.pub-cache
	cd $(APP) && flutter pub get
	cd $(APP) && flutter build apk --release
	@echo "$(GREEN)✅ Android limpo com sucesso$(NC)"

# ==========================================
# IOS
# ==========================================

ios_pods:
	@echo "$(GREEN)🍎 Instalando pods...$(NC)"
	cd $(APP)/ios && pod install

ios_update:
	@echo "$(GREEN)🍎 Atualizando pods...$(NC)"
	cd $(APP)/ios && pod update --repo-update

ios_clean:
	@echo "$(GREEN)🍎 Limpando iOS...$(NC)"
	rm -rf $(APP)/ios/Pods
	rm -rf $(APP)/ios/Podfile.lock
	cd $(APP)/ios && xcodebuild clean || true
	# DerivedData pode estar em uso pelo Xcode — não abortar o make
	rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex 2>/dev/null || true

ios_reset: ios_clean ios_pods
	@echo "$(GREEN)✅ iOS resetado$(NC)"

ios_run:
	@echo "$(GREEN)🍎 Rodando no iOS...$(NC)"
	cd $(APP) && flutter run -d ios

ios_build: ios_pods
	@echo "$(GREEN)🍎 Build release iOS...$(NC)"
	cd $(APP) && flutter build ios --release

open_ios:
	@echo "$(GREEN)🍎 Abrindo Xcode...$(NC)"
	open $(APP)/ios/Runner.xcworkspace

deep_clean_ios:
	@echo "$(GREEN)🔥 Limpeza profunda iOS...$(NC)"
	cd $(APP) && flutter clean
	rm -rf $(APP)/ios/Pods
	rm -rf $(APP)/ios/Podfile.lock
	rm -rf $(APP)/ios/.symlinks
	rm -rf $(APP)/ios/Flutter/Flutter.framework
	rm -rf $(APP)/ios/Flutter/App.framework
	rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex 2>/dev/null || true
	cd $(APP) && flutter pub get
	cd $(APP)/ios && pod deintegrate || true
	cd $(APP)/ios && pod install
	@echo "$(GREEN)✅ iOS limpo com sucesso$(NC)"

# ==========================================
# UTILITÁRIOS
# ==========================================

doctor:
	@echo "$(GREEN)👨‍⚕️ Verificando ambiente Flutter...$(NC)"
	flutter doctor -v

upgrade:
	@echo "$(GREEN)⬆️ Atualizando Flutter e dependências...$(NC)"
	flutter upgrade
	cd $(APP) && flutter pub upgrade

clean_cache:
	@echo "$(GREEN)🗑️ Limpando caches globais...$(NC)"
	rm -rf ~/.gradle/caches/
	rm -rf ~/.pub-cache
	rm -rf ~/.dartServer

fix_permissions:
	@echo "$(GREEN)🔧 Corrigindo permissões...$(NC)"
	chmod +x $(APP)/android/gradlew || true
	chmod +x $(APP)/ios/**/*.sh || true

# ==========================================
# HELP
# ==========================================

help:
	@echo ""
	@echo "$(GREEN)📋 Comandos disponíveis (app: $(APP)/)$(NC)"
	@echo ""
	@echo "Flutter:"
	@echo "  make clean"
	@echo "  make get"
	@echo "  make reset"
	@echo "  make reset_hard"
	@echo ""
	@echo "Execução:"
	@echo "  make run"
	@echo "  make run_release"
	@echo "  make run_profile"
	@echo ""
	@echo "Build:"
	@echo "  make apk"
	@echo "  make aab"
	@echo ""
	@echo "Android:"
	@echo "  make android_clean"
	@echo "  make deep_clean_android"
	@echo ""
	@echo "iOS:"
	@echo "  make ios_pods"
	@echo "  make ios_reset"
	@echo "  make ios_run"
	@echo "  make ios_build"
	@echo "  make open_ios"
	@echo "  make deep_clean_ios"
	@echo ""
	@echo "Utilitários:"
	@echo "  make doctor"
	@echo "  make upgrade"
	@echo "  make clean_cache"
