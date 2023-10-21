local flush_lookup = require(script.flushes)
local unique5_lookup = require(script.unique5)
local pairplus_lookup = require(script.pairplus)

local suits = {
	["C"] = 8,
	["D"] = 4,
	["H"] = 2,
	["S"] = 1
}

local info = {
	['2'] = {['rankbits'] = 1, ['rank'] = 0, ['prime'] = 2},
	['3'] = {['rankbits'] = 2, ['rank'] = 1, ['prime'] = 3},
	['4'] = {['rankbits'] = 4, ['rank'] = 2, ['prime'] = 5},
	['5'] = {['rankbits'] = 8, ['rank'] = 3, ['prime'] = 7},
	['6'] = {['rankbits'] = 16, ['rank'] = 4, ['prime'] = 11},
	['7'] = {['rankbits'] = 32, ['rank'] = 5, ['prime'] = 13},
	['8'] = {['rankbits'] = 64, ['rank'] = 6, ['prime'] = 17},
	['9'] = {['rankbits'] = 128, ['rank'] = 7, ['prime'] = 19},
	['T'] = {['rankbits'] = 256, ['rank'] = 8, ['prime'] = 23},
	['J'] = {['rankbits'] = 512, ['rank'] = 9, ['prime'] = 29},
	['Q'] = {['rankbits'] = 1024, ['rank'] = 10, ['prime'] = 31},
	['K'] = {['rankbits'] = 2048, ['rank'] = 11, ['prime'] = 37},
	['A'] = {['rankbits'] = 4096, ['rank'] = 12, ['prime'] = 41},
}

local function get_bits(rank, suit)
	local rankbit = info[rank]['rankbits']
	local ranknum = info[rank]['rank']
	local primenum = info[rank]['prime']
	local suitnum = suits[suit]

	local bits = bit32.bor(bit32.lshift(rankbit, 16), bit32.lshift(suitnum, 12), bit32.lshift(ranknum, 8), primenum)
	return bits
end

local function getLeftmost16Bits(number)
	return bit32.rshift(bit32.band(number, 0xFFFF0000), 16)
end

local function getPrimeFromBits(bits)
	return bit32.band(bits, 0x3F)  -- 0x3F is 00111111 in binary, which will mask the 6 rightmost bits
end

local function computeLeft16BitwiseOr(hand_bits)
	local key = 0
	for _, bits in ipairs(hand_bits) do
		key = bit32.bor(key, getLeftmost16Bits(bits))
	end
	return key
end

local function handToBits(hand)
	local bitsArray = {}
	for _, card in ipairs(hand) do
		local bits = get_bits(card.rank, card.suit)
		table.insert(bitsArray, bits)
	end
	return bitsArray
end

local function isFlush(hand_bits)
	local mask = 0xF000 -- The mask for the CDHS bits (4 bits set in the most significant part)

	local suit_bits = bit32.band(mask, hand_bits[1])  -- Initialize with the suit of the first card
	for i = 2, #hand_bits do
		if suit_bits ~= bit32.band(mask, hand_bits[i]) then
			return false  -- If suits don't match, then it's not a flush
		end
	end
	return true
end

local EvaluateFiveCardHand = function(hand)
	local hand_bits = handToBits(hand)
	local lookup_number = computeLeft16BitwiseOr(hand_bits)
	if isFlush(hand_bits) then
		local lookup_entry = flush_lookup[lookup_number] -- Adjust as needed if flush_lookup expects a different input format
		if lookup_entry then
			return lookup_entry['rank'], lookup_entry['name']
		else
			error("Flush lookup failed!")
		end
	elseif unique5_lookup[lookup_number] then  -- Adjust as needed if unique5_lookup expects a different input format
		local lookup_entry = unique5_lookup[lookup_number]
		return lookup_entry['rank'], lookup_entry['name']
	else
		local product_of_primes = 1
		for _, bits in ipairs(hand_bits) do
			product_of_primes = product_of_primes * getPrimeFromBits(bits)
		end
		local lookup_entry = pairplus_lookup[product_of_primes]
		if lookup_entry then
			return lookup_entry['rank'], lookup_entry['name']
		else
			error("Hand rank lookup failed!")
		end
	end
end

local EvaluateSevenCardHand = function(hand)
	-- 7 choose 5 is 21 possible combinations; we will loop through all of them and choose the best one
	local bestRank = 8192
	local bestHandName = ""

	-- Iterate through all 21 combinations
	for i = 1, 7 do
		for j = i + 1, 7 do
			for k = j + 1, 7 do
				for l = k + 1, 7 do
					for m = l + 1, 7 do
						local currentHand = {hand[i], hand[j], hand[k], hand[l], hand[m]}
						local currentRank, currentHandName = EvaluateFiveCardHand(currentHand)
						if currentRank < bestRank then
							bestRank = currentRank
							bestHandName = currentHandName
						end
					end
				end
			end
		end
	end

	return bestRank, bestHandName
end

local Evaluate = function(hand)
	if #hand == 7 then
		return EvaluateSevenCardHand(hand)
	elseif #hand == 5 then
		return EvaluateFiveCardHand(hand)
	else
		error("Invalid hand size! Hands must be 5 cards or 7 cards!")
	end
end

return Evaluate
