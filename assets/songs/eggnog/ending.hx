import flixel.FlxG;
import music.Song;
import states.PlayState;
import backend.scripting.events.CancellableEvent;
import backend.utilities.FNFSprite;

function onEndSong(event:CancellableEvent) {
	if (PlayState.isStoryMode) {
		event.cancel();

		var blacc:FNFSprite = new FNFSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, 0xFF000000);
		add(blacc);
		blacc.screenCenter();
		blacc.cameras = [camGame];
		blacc.scrollFactor.set();
		camHUD.visible = false;

		FlxG.sound.play(Paths.sound('game/christmas/lightsOff'), 1, false, null, true, function() {
			PlayState.SONG = Song.loadChart('winter horrorland', PlayState.storyDifficulty);
			FlxG.switchState(new PlayState());
		});
			
	}
}
