package jp_2dgames.game;

import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg {
  // フォントのパス
  public static inline var PATH_FONT = "assets/font/PixelMplus10-Regular.ttf";

  // フォントサイズ
  public static inline var FONT_SIZE = 20;
  public static inline var FONT_SIZE_S = 16;

  // UI領域
  public static inline var UI_WIDTH = 212;

  // ゲーム領域の中心座標を取得する

  public static function centerX():Float {
    return (FlxG.width - UI_WIDTH) / 2;
  }

  public static function centerY():Float {
    return FlxG.height / 2;
  }

  // ■色
  public static inline var COLOR_LISTITEM_ENABLE:Int = 0x006666;
  public static inline var COLOR_LISTITEM_DISABLE:Int = 0x003333;
  public static inline var COLOR_LISTITEM_TEXT:Int = 0x99FFCC;
  public static inline var COLOR_CURSOR:Int = FlxColor.YELLOW;

}