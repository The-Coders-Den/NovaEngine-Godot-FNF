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

## Only available on on_display_combo_post
var combo_sprites:Array[VelocitySprite]

func _init(judgement:Timings.Judgement, combo:int, late:bool, judgement_sprite:VelocitySprite, combo_sprites:Array[VelocitySprite]):
	self.judgement = judgement
	self.combo = combo
	self.late = late
	self.judgement_sprite = judgement_sprite
	self.combo_sprites = combo_sprites
