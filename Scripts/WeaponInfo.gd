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
@export var maxDistance:float
@export var bulletSpeed:float
@export var maxAmmo:int
@export var magCapacity:int
@export var reloadSpeed:float

@export_group("Visual")
@export var sprite:SpriteFrames
@export var spriteBullet:Texture
@export var spriteUI:Texture
@export var shootPos:Vector2
@export var shootExplosion:Array[Explosion.Type]

@export_group("Weapon Collision")
@export var collPos:Vector2
@export var collShape:Shape2D
