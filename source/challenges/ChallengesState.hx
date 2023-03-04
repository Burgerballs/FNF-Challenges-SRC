package challenges;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class ChallengesState extends MusicBeatState
{
	var cools:Array<ChallengeData> = [];
    var options:Array<String>;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Challenges Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xff292b97;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
        var http = new haxe.Http("https://raw.githubusercontent.com/Burgerballs/FNF-Challenges/main/challengeList.json");

        http.onData = function (data:String)
        {
            var stuff:Dynamic = Json.parse(data);

            options = Reflect.getProperty(stuff, "forever");
        }

        http.onError = function (error) {
            trace('error: $error');
        }

        http.request();

		for (i in 0...options.length)
		{
            var http = new haxe.Http("https://raw.githubusercontent.com/Burgerballs/FNF-Challenges/main/challenges/" + options[i] + '.json');
            http.onData = function (data:String)
            {
                var cooldata:Dynamic = Json.parse(data);
                var name = Reflect.getProperty(cooldata, "name");
                var desc = Reflect.getProperty(cooldata, "desc");
                var modifier = Reflect.getProperty(cooldata, "modifier");
                var songShit = [Reflect.getProperty(cooldata, "song"), Reflect.getProperty(cooldata, "difficulty")];

                //big ass shit
                cools.push(new ChallengeData(name,desc,modifier,songShit));
            }
            http.onError = function (error) {
                trace('error: $error');
            }
            http.request();

			var optionText:Alphabet = new Alphabet(0, 0, cools[i].name, true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (cools.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			// nuh uh
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = cools.length - 1;
		if (curSelected >= cools.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

class ChallengeData {
    public var name:String = 'NONAME';
    public var desc:String = 'NODESC';
    public var modifier:String = 'NOMOD';
    public var songShit:Array<String> = [
        'Bopeebo',
        'Hard'
    ];

    public function new(name:String, desc:String, modifier:String, songShit:Array<String>) {
        this.name = name;
        this.desc = desc;
        this.modifier = modifier;
        this.songShit = songShit;
    }
}