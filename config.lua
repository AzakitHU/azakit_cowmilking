LANGUAGE = 'en'

FrameworkType = "ESX" -- or "QBCore"
BUCKET = "bucket"  -- Is mandatory to start milking cows
BUCKETMILK = "bucketmilk" -- The reward of milking cows
InteractionType = "ox_target" -- Options: "ox_target" or "qb-target"

FILLS = true  -- If true, the bucket milk becomes a usable item and can be filled into the bottles.
BOTTLE = "bottle"  -- Bootle item
BOTTLE_AMOUNT = 5  -- 1 bucket = 5 bootle milk
HOMEMILK = "homemademilk" -- The reward for emptying the full bucket, the empty bucket is returned.

Cow = {
    {
        cowCoords = vector4(2250.1177, 4909.5264, 39.7279, 313.6317), -- x, y, z, heading
        cowsettings = {
            Freezecow = false, -- Freeeze Cow
            Invincible = true, -- Invincible Cow
            BlockingOfNonTemporaryEvents = true, -- SetBlockingOfNonTemporaryEvents
        },
    },
    {
        cowCoords = vector4(2234.4275, 4925.3271, 40.8214, 278.4554), -- x, y, z, heading
        cowsettings = {
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

-- Skill Check Configuration
SkillCheckDifficulty = {'easy', 'easy', 'easy', 'easy'}  -- Difficulty levels for skill checks (e.g., 'easy', 'medium', 'hard').
SkillCheckKeys = {'w', 'a', 's', 'd'}  -- Keys that must be pressed during the skill check.

Webhook = "" -- Discord Webhook
