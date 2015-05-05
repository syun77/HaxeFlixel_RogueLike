package ;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * メッセージウィンドウ
 **/
class Message extends FlxGroup {

	// メッセージの最大
	private static inline var MESSAGE_MAX = 5;
	// ウィンドウ座標
	private static inline var POS_X = 8;
	private static inline var POS_Y = 320 + 8;
	// ウィンドウサイズ
	private static inline var WIDTH = 640 - 8*2;
	private static inline var HEIGHT = 160 - 8*2;
	private static inline var MSG_POS_X = 8;
	private static inline var MSG_POS_Y = 8;
	// メッセージ表示間隔
	private static inline var DY = 26;

	// インスタンス
	public static var instance:Message = null;

	// 基準座標
	private var x:Float = POS_X; // X座標
	private var y:Float = POS_Y; // Y座標

	// メッセージの追加
	public static function push(msg:String) {
		Message.instance.pushMsg(msg);
	}

	private var _msgList:List<FlxText>;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();
		// 背景枠
		var spr = new FlxSprite(POS_X, POS_Y).makeGraphic(WIDTH, HEIGHT, FlxColor.BLACK);
		spr.alpha = 0.5;
		this.add(spr);
		_msgList = new List<FlxText>();
	}

	/**
	 * メッセージを末尾に追加
	 **/
	public function pushMsg(msg:String) {
		var text = new FlxText(x + MSG_POS_X, 0, 480);
		text.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		text.text = msg;
	  if(_msgList.length >= MESSAGE_MAX) {
	    // 最大を超えたので先頭のメッセージを削除
		  pop();
	  }
		_msgList.add(text);

		// 座標を更新
		var idx = 0;
		for(t in _msgList) {
			t.y = y + MSG_POS_Y + idx * DY;
			idx++;
		}
		this.add(text);
	}

	/**
	 * 先頭のメッセージを削除
	 **/
	public function pop() {
		var t = _msgList.pop();
		this.remove(t);
	}
}
