# This mini-game demonstrates how to create a custom currency system, 
# implement looting, and allow items to be purchased with the currency.
# Instructions for use:
# 1. Place a player_spawner_device, button_device, and item_granter_device in the world.
# 2. Link these items to the mini_tycoon creative_device.
# 3. Build the verse code once to allow UEFN to recognize the Tags.
# 4. Place a collectible_object_device (such as a coin) in the world, and tag it with CurrencyTag.
# 5. Duplicate the collectible_object_device as many times as desired.
# Now, start the game. Players can collect coins and purchase items by clicking the button. The ItemGranter will grant the purchased item to the player. 

# This examples demonstrates how to use the following features:
# - Using Tags to identify objects in the world.
# - Using CustomPlayer for multiple players gameplay
# - Keep track of currency for each player via the UI message.
# Tested with UEFN 28.20, Unreal Editor 5.4.0
# Created by: Almagi - Nhapq

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Please check VerveTagMarkup feature to see how to use tags in UEFN
CurrencyTag := class(tag){}
SpawnerTag := class(tag){}


mini_tycoon := class(creative_device):

    var PlayersMap:[player]custom_player = map{}

    @editable
    BuyButton:button_device = button_device{}

    @editable
    ItemGranter:item_granter_device = item_granter_device{}

    @editable
    ItemPrice : int = 20

    @editable
    PlayerSpawner: player_spawner_device = player_spawner_device{}

    # for example, if we loot a gold coin, its value could be 10 currency unit, \
    # if we loot a diamond, that could be 100 currecy unit
    @editable
    ValueOfEachItem : int = 10

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        InitCollectibleCurrecyItems()
        BuyButton.InteractedWithEvent.Subscribe(OnBuyButtonClicked)

    
    OnPlayerSpawned(Agent: agent):void=
        if: 
            Player := player[Agent]
        then:
            if (Existing := PlayersMap[Player]) {}
            else:
                if:
                    FC := Player.GetFortCharacter[]
                then:
                    CustomPlayer: custom_player = custom_player{Player:= Player}
                    option:
                        set PlayersMap[Player] = CustomPlayer
                    CustomPlayer.InitUI()
        
        
    InitCollectibleCurrecyItems():void=
        CollectibleCurrecyItems := GetCreativeObjectsWithTag(CurrencyTag{})

        for (CurrencyItem: CollectibleCurrecyItems, CurrencyObj := collectible_object_device[CurrencyItem]):
            CurrencyObj.CollectedEvent.Subscribe(OnCurrencyItemCollected)


    OnCurrencyItemCollected(Agent : agent):void=
        if (Player := player[Agent], CustomPlayer := PlayersMap[Player]) {
            CustomPlayer.AddCurrency(ValueOfEachItem)
            Print("Loot: {ValueOfEachItem}")
        }

    OnBuyButtonClicked(Agent: agent):void=
        if (Player := player[Agent]):
            if (CustomPlayer := PlayersMap[Player]) {
                if (CustomPlayer.Currency >= ItemPrice) {
                    CustomPlayer.SubtractCurrency(ItemPrice)
                    ItemGranter.GrantItem(Player)
                } else {
                    Print("Not enough currency")
                }
            }

    OnPlayerLeft(Player: player):void=
        if (CustomPlayer := PlayersMap[Player]) {
            # clear player from the map
            var TempMap: [player]custom_player = map{}
            for (K -> V : PlayersMap, K <> Player):
                set TempMap = ConcatenateMaps(TempMap, map{K => V})
            set PlayersMap = TempMap
        }


    

