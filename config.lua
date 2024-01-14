LANGUAGE = 'en'

BUCKET = "bucket"  -- Is mandatory to start milking cows
BUCKETMILK = "bucketmilk" -- The reward of milking cows

FILLS = true  -- If true, the bucket milk becomes a usable item and can be filled into the bottles.
BOTTLE = "bottle"  -- Bootle item
BOTTLE_AMOUNT = 5  -- 1 bucket = 5 bootle milk
HOMEMILK = "homemademilk" -- The reward for emptying the full bucket, the empty bucket is returned.

Cow = {
    {
        cowCoords = vector4(2250.1177, 4909.5264, 39.7279, 313.6317), -- x, y, z, heading
        cowettings = {
            Freezecow = false, -- Freeeze Cow
            Invincible = true, -- Invincible Cow
            BlockingOfNonTemporaryEvents = true, -- SetBlockingOfNonTemporaryEvents
        },
    },
    {
        cowCoords = vector4(2234.4275, 4925.3271, 40.8214, 278.4554), -- x, y, z, heading
        cowettings = {
            Freezecow = false,
            Invincible = true,
            BlockingOfNonTemporaryEvents = true, 
        },
    },
}

Check = {
    EnableSkillCheck = true, -- OX_LIB Skill Check.
    ProcessTime = 5, -- second - Only used when EnableSkillCheck is false.
}

Webhook = ""
