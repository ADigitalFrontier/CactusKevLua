# CactusKevLua
CactusKev's Poker hand ranking implemented in easy to use Lua format. Accepts both 5 card and 7 card hands.
Designed for Roblox

Example usage:

```lua
local HandEvaluator = require(script.Parent.HandEvaluator)

-- Define test cases
local testHands = {
	RF  = {"AC", "KC", "QC", "JC", "TC"},
	SF  = {"8C", "7C", "6C", "5C", "4C"},
	Q   = {"9D", "9C", "9H", "9S", "2C"},
	FH  = {"5D", "5C", "5H", "7S", "7H"},
	F   = {"2H", "4H", "6H", "9H", "JH"},
	S   = {"2S", "3H", "4S", "5C", "6D"},
	T   = {"KD", "KC", "KH", "3S", "4D"},
	TwoP= {"2D", "2C", "6S", "6H", "9D"},
	OneP= {"JC", "JD", "4H", "7C", "9S", "2H", "3H"}
}

local function convertToHandFormat(cards)
	local hand = {}
	for _, card in ipairs(cards) do
		table.insert(hand, {rank=string.sub(card, 1, -2), suit=string.sub(card, -1)})
	end
	return hand
end

-- Run the tests
for handType, cards in pairs(testHands) do
	local hand = convertToHandFormat(cards)
	local rank, handName = HandEvaluator(hand)
	print(handType, ":", rank, "-", handName)
end

print("All tests complete!")
```

Test output:
```
  17:32:31.297  SF : 7 - Eight-High Straight Flush  -  Server - test:28
  17:32:31.298  FH : 282 - Fives Full over Sevens  -  Server - test:28
  17:32:31.298  TwoP : 3254 - Sixes and Deuces  -  Server - test:28
  17:32:31.298  T : 1739 - Three Kings  -  Server - test:28
  17:32:31.298  RF : 1 - Royal Flush  -  Server - test:28
  17:32:31.298  F : 1438 - Jack-High Flush  -  Server - test:28
  17:32:31.298  S : 1608 - Six-High Straight  -  Server - test:28
  17:32:31.298  OneP : 4158 - Pair of Jacks  -  Server - test:28
  17:32:31.298  Q : 82 - Four Nines  -  Server - test:28
```
