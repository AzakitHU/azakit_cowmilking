# Milking a cow
You can milk the cows if you have a bucket. You can pour homemade milk from the bucket into bottles.
Everything can be easily changed in the config.lua file.

* Easy configuration
* Spawned cow
* Checking items
* Skill Check
* Usable item
* Discord Webhook

# Preview
https://www.youtube.com/watch?v=Fbr0rSMUAyU

# Install
- Clone or Download the [repository](https://github.com/AzakitHU/azakit_cowmilking).
- Add the **azakit_cowmilking** to your resources folder.
- Add `ensure azakit_cowmilking` to your **server.cfg**.

# OX Inventory Items
	
	['bottle'] = {
		label = 'Bottle',
		weight = 20,
		stack = true,
		close = true,
		description = nil
	},

	['bucket'] = {
		label = 'Bucket',
		weight = 20,
		stack = true,
		close = true,
		description = nil
	},

	['bucketmilk'] = {
		label = 'Bucket Milk',
		weight = 520,
		stack = true,
		close = true,
		description = nil,
		client = {
			export = "azakit_cowmilking.useItem"
		}
	},

	['homemademilk'] = {
		label = 'Homemade milk',
		weight = 120,
		stack = true,
		close = true,
		description = nil
	},

# Requirements
- ESX
- ox_lib
- ox_target

# Documentation
You can find [Discord](https://discord.gg/DmsF6DbCJ9).
