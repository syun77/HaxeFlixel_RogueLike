package jp_2dgames.game.gui;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ナイトメア管理
 **/
class GuiNightmare extends FlxSpriteGroup {

  // 基準座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 384 + 8;

  // 背景のサイズ
  private static inline var WIDTH = 212 - 8*2;
  private static inline var HEIGHT = 48 + 8*2;

  // 標示物の座標
  private static inline var INFO_X = 8;
  private static inline var INFO_Y = 8;
  private static inline var TURN_X = 8;
  private static inline var TURN_Y = 32;

  // 残りターン数
  private var _turnLimit:Int;

  // ターン数のテキスト
  private var _txtInfo:FlxText;
  private var _txtTurn:FlxText;

  public function new() {
    super(POS_X, POS_Y);

    // 背景
    var sprBg = new FlxSprite(0, 0).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    sprBg.color = FlxColor.GRAY;
    sprBg.alpha = 0.4;
    this.add(sprBg);

    // キャプション
    _txtInfo = new FlxText(INFO_X, INFO_Y, 0, 160);
    _txtInfo.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtInfo);
    _txtInfo.text = "ナイトメア Lv1";

    // ターン数のテキスト
    _txtTurn = new FlxText(TURN_X, TURN_Y, 0, 160);
    _txtTurn.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtTurn);

    _turnLimit = 0;
  }

  /**
   * ターン数を設定する
   **/
  public function setTurn(turnCount:Int):Void {
    if(_turnLimit != turnCount) {
      // 値が前回と違っていたら更新
      _turnLimit = turnCount;
      _txtTurn.text = '残り${turnCount}ターン';

      if(_turnLimit < 10) {
        // 文字を赤くする
        _txtInfo.color = FlxColor.SALMON;
      }
      else {
        // 文字を白にする
        _txtInfo.color = FlxColor.WHITE;
      }
      _txtTurn.color = _txtInfo.color;
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    setTurn(Global.getTurnLimitNightmare());
  }
}
