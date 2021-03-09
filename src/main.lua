local GREY_QUALITY = 0
local CANNOT_BE_SOLD = 0

Vendie = { }

local f = CreateFrame("Frame")

function ConvertToGoldSilverCopper(total)
  local gold = math.floor(total / 10000)
  local silver = math.floor(total % 10000/100)
  local copper = total % 100

  return gold, silver, copper
end

function SellAllItems()
  local total = 0
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = GetContainerItemLink(bag, slot)

      if item then
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
        itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
        isCraftingReagent = GetItemInfo(item)

        if itemRarity == GREY_QUALITY then
          if itemSellPrice ~= CANNOT_BE_SOLD then
            total = (itemSellPrice * itemStackCount) + total
            UseContainerItem(bag, slot)
          else 
            PickupContainerItem(bag, slot);
            DeleteCursorItem();
          end
        end
      end
    end
  end

  if total > 0 then
    local gold, silver, copper = ConvertToGoldSilverCopper(total)
    DEFAULT_CHAT_FRAME:AddMessage("[Vendie] Sold grey items for "..gold.."g "..silver.."s "..copper.."c")
  end
end

function Repair()
  if CanMerchantRepair() then
    local cost, needed = GetRepairAllCost()

    if cost > 0 and needed then
      local canUseGuildFunds = false
      if GetGuildBankWithdrawMoney() > 0 then
        canUseGuildFunds = true
      end

      RepairAllItems(canUseGuildFunds)

      local gold, silver, copper = ConvertToGoldSilverCopper(cost)
      DEFAULT_CHAT_FRAME:AddMessage("[Vendie] Repaired for "..gold.."g "..silver.."s "..copper.."c")
    end
  end
end

function Vendie:MERCHANT_SHOW()
  SellAllItems()
  Repair()
end

f:SetScript("OnEvent", function(self, event) 
  Vendie[event](self, event)
end)

for k,v in pairs(Vendie) do
  f:RegisterEvent(k)
end
