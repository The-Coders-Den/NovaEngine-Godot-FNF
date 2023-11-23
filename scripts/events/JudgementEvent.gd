class_name JudgementEvent extends CancellableEvent

## The judgement you got upon hitting a note.
## You can obtain data like health gain, accuracy gain,
## etc with this.
var judgement:Timings.Judgement

## combo shit
var combo:int

## Whether or not the note was hit late.
var late:bool

## Only available on on_display_judgement_post
var judgement_sprite:VelocitySprite

## Only available on on_display_judgement_post
var judgement_tween:Tween

## Only available on on_display_combo_post
var combo_sprites:Array[VelocitySprite] = []

## Only available on on_display_combo_post
var combo_tweens:Array[Tween] = []

func _init(_judgement:Timings.Judgement, _combo:int, _late:bool):
	self.judgement = _judgement
	self.combo = _combo
	self.late = _late
