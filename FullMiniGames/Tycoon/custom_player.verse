using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }


custom_player := class<unique>():

    Player : player
    var Currency : int = 0

    # UI
    StringToMessage<localizes>(messageText: string) : message = "{messageText}"
    var CurrencyUI : text_block = text_block{}

    InitUI():void=
        set  CurrencyUI = text_block{DefaultText := StringToMessage("Coins: {Currency}")}
        CurrencyWidget : canvas = CreateCanvas(CurrencyUI)

        if (UI := GetPlayerUI[Player]) {
            UI.AddWidget(CurrencyWidget)
        }

    
    CreateCanvas(TextBlock: text_block):canvas=
        Canvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.15}, Maximum := vector2{X := 0.5, Y := 0.15}}
                    Offsets := margin{Top := 0.0, Bottom := 0.0, Left := 0.0, Right := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    SizeToContent := true
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultColor := NamedColors.Grey
                                    DefaultOpacity := 0.2
                                    DefaultDesiredSize := vector2{X := 400.0, Y := 50.0}
                            overlay_slot:
                                Widget := TextBlock
        return Canvas

    
    AddCurrency(Amount:int):void=
        set Currency += Amount
        UpdateCurrencyUI()
        Print("Receive: {Currency}")


    SubtractCurrency(Amount:int):void=
        set Currency -= Amount
        UpdateCurrencyUI()
        Print("Spent: {Currency}")


    UpdateCurrencyUI():void=
        CurrencyUI.SetText(StringToMessage("Coins: {Currency}"))
