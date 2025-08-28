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
@export var weaponType:type = type.Ranged

@export_group("Stats")
@export var attackSpeed:float = 0.3
@export var baseDmg:float = 1.0
@export_subgroup("Melee")
@export var slashScale = 6.0
@export_subgroup("Ranged")
@export var maxDistance:float
@export var bulletSpeed:float
@export var maxAmmo:int = 200
@export var magCapacity:int = 12
@export var reloadSpeed:float = 1.5

@export_group("Visual")
@export var sprite:SpriteFrames
@export var spriteUI:Texture
@export var shootPos:Vector2
@export_subgroup("Ranged")
@export var spriteBullet:Texture
@export var shootExplosion:Array[Explosion.Type]

@export_group("Weapon Collision")
@export var collPos:Vector2
@export var collShape:Shape2D
