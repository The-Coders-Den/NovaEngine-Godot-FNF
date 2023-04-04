import flixel.FlxG;

function onStepHit(step) {
	switch (step) {
		case 156, 412:
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			
		case 188, 444:
			bf.playAnim('hey', true);
			bf.specialAnim = true;
	}
}
