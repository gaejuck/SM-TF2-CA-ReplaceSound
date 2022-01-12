# Custom Attribute : Replace Sound
  
It is a custom attribute that replace the existing original sound with custom sound,  
written for [the Custom Attribute framework](https://github.com/nosoop/SM-TFCustAttr).

In fact, I wanted to use [SM TF2 ReplaceSound](https://github.com/JessicaTheGunLady/SM-TF2-ReplaceSound), but it didn't work properly. So I made another one.

## Config explanation

It would check the `ca_replace_sound.cfg`. And like the example below, you can fill it out.
```
"SoundGroup"
{
	"classic" // Name the sound group.
	{
		// Write the original sound and the replacement sound separately.
		"old sound"							"new sound" 
		.
		.
		.
		// Like this.
		// The example is to change the SMG shoot sound to classic shoot sound.
		")weapons/smg_shoot.wav"			")weapons/sniper_rifle_classic_shoot.wav"
		")weapons/smg_shoot_crit.wav"		")weapons/sniper_rifle_classic_shoot_crit.wav"
	}
}
```
If you want to know what the game sounds,  
you can look inside `.../tf2_misc_dir.vpk/scripts/game_sounds_weapons.txt`.  
all of the sounds weapons refer to should be here.

Now, apply the corresponding sound group to custom weapon as shown below.
```
"attributes_custom"
{
	"replace sound"						"classic"
}
```

## Command
* `ca_sound_replace_reload` - Reload the created sound group.
