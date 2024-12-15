package;

import flixel.FlxG;
import flixel.FlxState;
import lime.app.Application;

#if windows
@:headerCode("#include <windows.h>")
#elseif linux
@:headerCode("#include <stdio.h>")
#end
class SpecsDetector extends FlxState
{
	var cache:Bool = false;
	var isCacheSupported:Bool = false;

	override public function create()
	{
		KadeEngineData.initSave();
		super.create();

		FlxG.save.data.cachestart = checkSpecs();
		FlxG.switchState(new Caching());
	}

	function checkSpecs():Bool
	{
		return true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	#if windows
	@:functionCode("
		// simple but effective code
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);

		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		// swag linux 😎😎😎😎😎
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
}
