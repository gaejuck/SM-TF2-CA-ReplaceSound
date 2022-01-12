#include <sdktools_sound>
#include <tf_custom_attributes>

#define PLUGIN_VERSION	"1.0"

public Plugin myinfo =
{
	name		=	"[TF2] Custom Attribute : Replace Sound",
	author		=	"Mir",
	description	=	"Replace it to the sound you want.",
	url			=	"https://github.com/gaejuck/SM-TF2-CA-ReplaceSound",
	version		=	PLUGIN_VERSION
};

StringMap g_mSoundGroup;

enum struct SoundInfo
{
	StringMap mSound;
	
	void Destroy()
	{
		delete this.mSound;
	}
}

public void OnPluginStart()
{
	RegServerCmd("ca_sound_replace_reload", CommandReload);
	AddNormalSoundHook(SoundHook);
}

public void OnMapStart()
{
	InitReplaceSoundMap();
}

public void OnMapEnd()
{
	CleaningReplaceSoundMap();
}

public Action CommandReload(int args)
{
	CleaningReplaceSoundMap();
	InitReplaceSoundMap();
	
	return Plugin_Handled;
}

public Action SoundHook(int clients[MAXPLAYERS], int& iNumClients, char sOldSound[PLATFORM_MAX_PATH], int& iEntity, 
	int& iChannel, float& fVolume, int& iLevel, int& iPitch, int& iFlags, char sSoundEntry[PLATFORM_MAX_PATH], int& iSeed)
{
	if(!IsValidClient(iEntity)) return Plugin_Continue;
	
	int iWeapon = GetEntPropEnt(iEntity, Prop_Send, "m_hActiveWeapon");
	
	if (!IsValidEdict(iWeapon)) return Plugin_Continue;
	
	char sAttributes[256];		

	if(!TF2CustAttr_GetString(iWeapon, "sound replace", sAttributes, sizeof(sAttributes)))
	{
		return Plugin_Continue;
	}

	SoundInfo soundInfo;
	if(!g_mSoundGroup.GetArray(sAttributes, soundInfo, sizeof(soundInfo))) return Plugin_Continue;
	
	char sNewSound[PLATFORM_MAX_PATH];
	if(!soundInfo.mSound.GetString(sOldSound, sNewSound, sizeof(sNewSound))) return Plugin_Continue;
	
	if(sNewSound[0] == EOS) return Plugin_Continue;
	
	if(PrecacheSound(sNewSound, true))
	{
		EmitSoundToAll(sNewSound, iEntity, iChannel, iLevel, iFlags, fVolume, iPitch);
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

void InitReplaceSoundMap()
{
	char sBuildPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sBuildPath, sizeof(sBuildPath), "configs/ca_replace_sound.cfg");

	KeyValues kvSoundGroup = new KeyValues("SoundGroup");

	if(!kvSoundGroup.ImportFromFile(sBuildPath))
	{
		LogMessage("Error: %s not found", sBuildPath);
		return;
	}
	
	g_mSoundGroup = new StringMap();
	
	LoadSoundMap(kvSoundGroup, g_mSoundGroup);
	
	delete kvSoundGroup;
}

void LoadSoundMap(KeyValues kv, StringMap mReplaceSound)
{
	if(kv == null)
	{
		LogMessage("Error: config keyvalue not valid");
		return;
	}
	
	mReplaceSound.Clear();
	
	if(kv.GotoFirstSubKey(false))
	{
		do
		{
			SoundInfo soundInfo;
			soundInfo.mSound = new StringMap();
			
			char sName[256];
			kv.GetSectionName(sName, sizeof(sName));
			
			if (kv.GotoFirstSubKey(false))
			{
				do 
				{
					char sOldSound[PLATFORM_MAX_PATH], sNewSound[PLATFORM_MAX_PATH];
				
					kv.GetSectionName(sOldSound, sizeof(sOldSound));
					kv.GetString(NULL_STRING, sNewSound, sizeof(sNewSound));
					
					if(sNewSound[0] == EOS) continue;
	
					if(!PrecacheSound(sNewSound, true)) continue;
					
					soundInfo.mSound.SetString(sOldSound, sNewSound);
					
				} while(kv.GotoNextKey(false));
				
				g_mSoundGroup.SetArray(sName, soundInfo, sizeof(soundInfo));
				kv.GoBack();
			}
		} while(kv.GotoNextKey());
	}
}

void CleaningReplaceSoundMap()
{
	StringMapSnapshot soundList = g_mSoundGroup.Snapshot();
	
	char sName[PLATFORM_MAX_PATH];
	for (int i = 0; i < soundList.Length; i++)
	{
		soundList.GetKey(i, sName, sizeof(sName));
		
		SoundInfo soundInfo;
		g_mSoundGroup.GetArray(sName, soundInfo, sizeof(soundInfo));
		
		soundInfo.Destroy();
	}
	
	delete soundList;	
	delete g_mSoundGroup;
}

stock bool IsValidClient(int iClient, bool bReplaycheck = true)
{
	return (0 < iClient && iClient <= MaxClients && IsClientInGame(iClient) && !GetEntProp(iClient, Prop_Send, "m_bIsCoaching")
	&& !(bReplaycheck && (IsClientSourceTV(iClient) || IsClientReplay(iClient))));
}