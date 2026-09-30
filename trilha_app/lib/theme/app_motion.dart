import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

/// Tempo do app — uma batida só, como montagem de filme.
///
/// Entrada lenta e decidida ([enter]), saída rápida ([exit]), nada quica.
/// Todo `duration:` de animação usa um destes degraus; coreografias longas
/// (loops, respiração, contagens) ficam com o valor próprio.
class AppMotion {
  AppMotion._();

  /// Toque, troca de estado mínima.
  static const instant = Duration(milliseconds: 90);

  /// Resposta a toque: pressionar, marcar, abrir chip.
  static const quick = Duration(milliseconds: 160);

  /// Padrão de UI: cor, tamanho, troca de conteúdo.
  static const standard = Duration(milliseconds: 240);

  /// Entrada de bloco, sheet, troca de aba.
  static const gentle = Duration(milliseconds: 360);

  /// Revelação: herói, placar, resultado.
  static const slow = Duration(milliseconds: 520);

  /// Plano de cena: abertura, celebração, travessia.
  static const scene = Duration(milliseconds: 820);

  /// Intervalo entre itens que entram em sequência.
  static const stagger = Duration(milliseconds: 60);

  /// Chega decidido e pousa (expo-out).
  static const enter = Cubic(0.16, 1, 0.3, 1);

  /// Sai sem cerimônia.
  static const exit = Cubic(0.4, 0, 1, 1);

  /// Vai de um lugar a outro (câmera, posição).
  static const move = Cubic(0.65, 0, 0.35, 1);

  /// Pouso firme, sem quique — padrão de UI e de mundo.
  static const settle = Cubic(0.2, 0.9, 0.3, 1);

  /// Juice de recompensa — **só** quando algo é ganho (passos, medalha,
  /// baú, veredito, travessia). Nunca em chrome, navegação ou leitura.
  static const pop = Curves.easeOutBack;
  static const spring = Curves.elasticOut;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], ou zero quando o aparelho pede menos movimento.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}
