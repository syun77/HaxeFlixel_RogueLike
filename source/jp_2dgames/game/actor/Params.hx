package jp_2dgames.game.actor;

/**
 * キャラクターステータスパラメータ
 **/
class Params {
  public var id:Int = 1; // ID
  public var lv:Int = 1; // レベル
  public var exp:Int = 0; // 経験値
  public var xp:Int = 0; // 倒したときに得られる経験値
  public var hp:Int = 100; // 現在のHP
  public var hpmax:Int = 100; // 最大HP
  public var str:Int = 0; // 力
  public var vit:Int = 0; // 体力
  public var food:Int = 10000; // 満腹度(x100)
  public var foodmax:Int = 10000; // 最大満腹度(x100)
  public var badstatus:String = "none"; // バッドステータス
  public var badstatus_turn:Int = 0; // バッドステータスが有効なターン数

  public function new() {
  }

}
