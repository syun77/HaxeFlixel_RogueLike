package jp_2dgames.game;

import jp_2dgames.game.item.ThrowItem;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.GuiStatus;
import jp_2dgames.game.gui.Dialog;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.Actor.Action;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  KeyInput;       // キー入力待ち
  InventoryInput; // インベントリの操作中
  PlayerAct;      // プレイヤーの行動
  Firearm;        // 飛び道具
  EnemyRequestAI; // 敵のAI
  Move;           // 移動
  EnemyActBegin;  // 敵の行動開始
  EnemyAct;       // 敵の行動
  TurnEnd;        // ターン終了
  NextFloor;      // 次のフロアに進むかどうか
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr {
  private var _player:Player;
  private var _enemies:FlxTypedGroup<Enemy>;
  private var _inventory:Inventory;
  private var _guistatus:GuiStatus;
  private var _throwItem:ThrowItem;

  // 状態
  private var _state:State;
  private var _stateprev:State;

  /**
	 * コンストラクタ
	 **/
  public function new(state:PlayState) {
    _player = state.player;
    _enemies = Enemy.parent;
    _inventory = Inventory.instance;
    _guistatus = state.guistatus;

    _throwItem = new ThrowItem();

    _state = State.KeyInput;
    _stateprev = _state;
  }

  /**
	 * 状態遷移
	 **/
  private function _change(s:State):Void {
    _stateprev = _state;
    _state = s;

    // ヘルプ情報の更新
    var help:Int = _guistatus.helpmode;
    switch(_state) {
      case State.KeyInput:
        help = GuiStatus.HELP_KEYINPUT;
      case State.InventoryInput:
        help = GuiStatus.HELP_INVENTORY;
      case State.PlayerAct:
      case State.Firearm:
      case State.EnemyRequestAI:
      case State.Move:
      case State.EnemyActBegin:
      case State.EnemyAct:
      case State.TurnEnd:
      case State.NextFloor:
        help = GuiStatus.HELP_DIALOG_YN;
    }

    _guistatus.changeHelp(help);
  }

  /**
	 * 更新
	 **/
  public function update():Void {
    var cnt:Int = 0;
    var bLoop:Bool = true;
    while(bLoop) {
      bLoop = proc();
      cnt++;
      if(cnt > 100) {
        break;
      }
    }
  }

  /**
	 * 敵をすべて動かす
	 **/
  private function _moveAllEnemy():Void {
    _enemies.forEachAlive(function(e:Enemy) {
      if(e.action == Action.Move) {
        e.beginMove();
      }
    });
  }

  private function proc():Bool {
    _player.proc();
    _enemies.forEachAlive(function(e:Enemy) e.proc());

    // ループフラグ
    var ret:Bool = false;

    switch(_state) {
      case State.KeyInput:
        // ■キー入力待ち
        switch(_player.action) {
          case Action.Act:
            // プレイヤー行動
            _player.beginAction();
            _change(State.PlayerAct);
            ret = true;
          case Action.Move:
            // 移動した
            _change(State.EnemyRequestAI);
            ret = true;
          case Action.InventoryOpen:
            // インベントリを開く
            if(_inventory.checkOpen()) {
              // 開ける
              _inventory.setActive(true);
              _change(State.InventoryInput);
            }
            else {
              // 開けないのでキー入力に戻る
              _player.changeprev();
              Message.push2(Msg.INVENTORY_CANT_OPEN, null);
            }
          case Action.TurnEnd:
            // 足踏み待機
            _change(State.EnemyRequestAI);
            // 制御を返して連続で回復しないようにする
            ret = false;
          default:
          // 何もしていない
        }

        // 敵の情報を表示するかどうかチェックする
        _guistatus.checkEnemyInfo();

      case State.InventoryInput:
        // ■イベントリ操作中
        switch(_inventory.proc()) {
          case Inventory.RET_CONTINUE:
            // 処理を続ける
          case Inventory.RET_CANCEL:
            // キー入力に戻る
            _player.changeprev();
            // 非表示
            _inventory.setActive(false);
            _change(State.KeyInput);
          case Inventory.RET_DECIDE:
            // ターン終了
            _player.standby();
            // 非表示
            _inventory.setActive(false);
            _change(State.EnemyRequestAI);
          case Inventory.RET_THROW:
            // アイテムを投げた
            _player.standby();
            // 非表示
            _inventory.setActive(false);
            _throwItem.start(_player, _inventory.getThrowItem());
            _inventory.clearThrowItem();
            _change(State.Firearm);
        }

      case State.PlayerAct:
        // ■プレイヤーの行動
        if(_player.isTurnEnd()) {
          // 移動完了
          _change(State.EnemyRequestAI);
          ret = true;
        }

      case State.Firearm:
        // ■飛び道具の移動
        if(_throwItem.isEnd()) {
          _change(State.EnemyRequestAI);
        }

      case State.EnemyRequestAI:
        // 敵に行動を要求する
        _enemies.forEachAlive(function(e:Enemy) e.requestMove());
        if(_player.isTurnEnd()) {
          _change(State.EnemyActBegin);
          ret = true;
        }
        else {
          // プレイヤーの移動を開始する
          _player.beginMove();
          // 敵も移動する
          _moveAllEnemy();
          _change(State.Move);
          ret = true;
        }

      case State.Move:
        if(_player.isTurnEnd()) {
          _change(State.EnemyActBegin);
          ret = true;
        }

      case State.EnemyActBegin:
        var bStart = false;
        _enemies.forEachAlive(function(e:Enemy) {
          if(bStart == false) {
            // 誰も行動していなければ行動する
            if(e.action == Action.Act) {
              e.beginAction();
              bStart = true;
            }
          }
        });
        ret = true;
        _change(State.EnemyAct);

      case State.EnemyAct:
        // ■敵の行動
        var isNext = true;
        var isActRemain = false;
        var isMoveRemain = false;
        _enemies.forEachAlive(function(e:Enemy) {
          switch(e.action) {
            case Action.ActExec:
              // アクション実行中
              isNext = false;
            case Action.MoveExec:
              // 移動中
              isNext = false;
            case Action.Act:
              // アクション実行待ち
              isActRemain = true;
            case Action.Move:
              // 移動待ち
              isMoveRemain = true;
            case Action.TurnEnd:
            // ターン終了
            default:
              // 通常ここに来ない
              trace('Error: Invalid action = ${e.action}');
          }
        });
        if(isNext) {
          // 敵が行動完了した
          if(isActRemain) {
            // 次の敵を動かす
            _change(State.EnemyActBegin);
          }
          else if(isMoveRemain) {
            // 移動待ちの敵がいるので動かしてやる
            _moveAllEnemy();
          }
          else {
            _change(State.TurnEnd);
          }
          ret = true;
        }
      case State.TurnEnd:
        // ■ターン終了
        _enemies.forEachAlive(function(e:Enemy) e.turnEnd());
        if(_player.isOnStairs) {
          // 次のフロアに進む
          _change(State.NextFloor);
          Dialog.open(Dialog.SELECT2, "階段がある", ["下りる", "そのまま"]);
        }
        else {
          // キー入力に戻る
          _player.turnEnd();
          _change(State.KeyInput);
        }
        ret = true;

      case State.NextFloor:
        // ■次のフロアに進む
        if(Dialog.isClosed()) {
          if(Dialog.getCursor() == 0) {
            // 次のフロアに進む
            Global.nextFloor();
            FlxG.switchState(new PlayState());
          }
          else {
            // 階段を降りない
            _change(State.KeyInput);
            // 階段フラグを下げる
            _player.endOnStairs();
            _player.turnEnd();
          }
        }
    }

    return ret;
  }

}
