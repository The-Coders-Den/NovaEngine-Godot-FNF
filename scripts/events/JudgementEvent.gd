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
var combo_sprites:Array[VelocitySprite]

## Only available on on_display_combo_post
var combo_tweens:Array[Tween]

func _init(judgement:Timings.Judgement, combo:int, late:bool, judgement_sprite:VelocitySprite, judgement_tweens:Array[Tween], combo_sprites:Array[VelocitySprite], combo_tweens:Array[Tween]):
	self.judgement = judgement
	self.combo = combo
	self.late = late
	self.judgement_sprite = judgement_sprite
	self.judgement_tween = judgement_tween
	self.combo_sprites = combo_sprites
	self.combo_tweens = combo_tweens
