extends Resource

class_name WeaponInfo

enum type
{
	Melee,
	Ranged
}

@export_group("General")
@export var name:String
@export_multiline var desc:String
@export var weaponType:type

@export_group("Stats")
@export var attackSpeed:float
## Not applicable in melee type.
@export var maxDistance:float
## Not applicable in melee type.
@export var maxAmmo:int
## Not applicable in melee type.
@export var magCapacity:int

@export_group("Visual")
@export var sprite:SpriteFrames
@export var spriteBullet:Texture
@export var spriteUI:Texture
@export var shootPos:Vector2
@export var weaponVerification:Shape2D
@export var shootExplosion:Array[Explosion.Type]
