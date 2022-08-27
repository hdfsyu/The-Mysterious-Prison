package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var inCombat:Bool = false;
	var combatHud:CombatHUD;
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 3;
	var ending:Bool;
	var won:Bool;
	var coinSound:FlxSound;

	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
		{
			player.setPosition(entity.x, entity.y);
		}
		else if (entity.name == "coin")
		{
			coins.add(new Coin(entity.x + 4, entity.y + 4));
		}
		else if (entity.name == "enemy")
		{
			enemies.add(new Enemy(entity.x + 4, entity.y, REGULAR));
		}
		else if (entity.name == "boss")
		{
			enemies.add(new Enemy(entity.x + 4, entity.y, BOSS));
		}
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			money++;
			hud.updateHUD(health, money);
			coin.kill();
			coinSound.play(true);
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	function doneFadeOut()
	{
		FlxG.switchState(new GameOverState(won, money));
	}

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.theMysterousPrison__ogmo, AssetPaths.prison_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);
		coins = new FlxTypedGroup<Coin>();
		add(coins);
		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);
		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);
		hud = new HUD();
		add(hud);
		combatHud = new CombatHUD();
		add(combatHud);
		coinSound = FlxG.sound.load(AssetPaths.coin__wav);
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		super.create();
	}

	override public function update(elapsed:Float)
	{
		function startCombat(enemy:Enemy)
		{
			inCombat = true;
			player.active = false;
			enemies.active = false;
			combatHud.initCombat(health, enemy);
		}
		function playerTouchEnemy(player:Player, enemy:Enemy)
		{
			if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
			{
				startCombat(enemy);
			}
		}
		super.update(elapsed);
		if (ending)
		{
			return;
		}
		if (inCombat)
		{
			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
				}
				else
				{
					if (combatHud.outcome == VICTORY)
					{
						combatHud.enemy.kill();
						if (combatHud.enemy.type == BOSS)
						{
							won = true;
							ending = true;
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
						}
					}
					else
					{
						combatHud.enemy.flicker();
					}
					inCombat = false;
					#if mobile
					virtualPad.visible = true;
					#end
					player.active = true;
					enemies.active = true;
				}
			}
		}
		else
		{
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}
}
