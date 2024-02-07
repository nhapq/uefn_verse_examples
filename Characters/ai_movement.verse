
# This is a simple AI that will follow players and return to its spawn location when the player is out of range.
# How to use: 
# 1. Create a new Prop and link it to the ThisProp property
# 2. Set the MovingSpeed and DetectionRange properties to control the speed and range of the AI
# Tested with UEFN 28.20, Unreal Editor 5.4.0
# Created by: Almagi - Nhapq

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


enemy_ai := class(creative_device):

    # Link this with your prop
    @editable ThisProp : creative_prop = creative_prop{}

    # Change this value to control the speed of the Prop
    MovingSpeed : float = 200.0

    # Prop will detect players within this range
    DetectionRange : float = 2000.0

    MaxDistanceFromSpawnLocation : float = 3000.0

    var State : string = "Idle"

    var SpawnLocation : vector3 = vector3{}
    var SpawnRotation : rotation = rotation{}

    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        spawn:
            InitProp()

    InitProp()<suspends>:void=
        set SpawnLocation = ThisProp.GetTransform().Translation
        set SpawnRotation = ThisProp.GetTransform().Rotation

        loop:
            Sleep(0.1)
            AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                if (Agent := agent[Player], Fort := Agent.GetFortCharacter[], ThisProp.IsValid[]):
                    if: 
                        DistanceToPlayer := Distance(Fort.GetTransform().Translation, ThisProp.GetTransform().Translation)
                        DistanceToPlayer < DetectionRange
                        Distance(SpawnLocation, ThisProp.GetTransform().Translation) < MaxDistanceFromSpawnLocation
                        State = "Idle" or State = "Chase"
                    then:
                        set State = "Chase"
                        FollowPlayer(Player)
                    else:
                        set State = "Return"
                        ReturnToSpawnLocation()


    ReturnToSpawnLocation()<suspends>:void=
        if (ThisProp.IsValid[]):
            PropLocation := ThisProp.GetTransform().Translation
            if (LookDirection := (SpawnLocation - PropLocation).MakeUnitVector[]):
                Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                Roll := 0.0
                NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                ThisProp.MoveTo(PropLocation, NewRotation, 1.0)

            ThisProp.MoveTo(SpawnLocation, ThisProp.GetTransform().Rotation, (Distance(SpawnLocation, PropLocation) / MovingSpeed))
            ThisProp.MoveTo(SpawnLocation, SpawnRotation, 1.0)

            set State = "Idle"


    FollowPlayer(Player: player)<suspends>:void=
        # to avoid weird behavior when this prop is too close to the player
        MinDistanceToPlayer := 1.0
        # increase this value to make the prop move smoother
        Smoothness := 4.0

        if ( Fort := Player.GetFortCharacter[], ThisProp.IsValid[]):
            PlayerTran := Fort.GetTransform()
            PropTran := ThisProp.GetTransform()
            DistanceToPlayer := Distance(PlayerTran.Translation, PropTran.Translation)
            LerpedLocation := PropTran.Translation + (PlayerTran.Translation - PropTran.Translation)/Smoothness

            if (DistanceToPlayer > MinDistanceToPlayer):
                NewRotation := CalculateRotation(Player)
                ThisProp.MoveTo(vector3{X:=LerpedLocation.X,
                     Y:=LerpedLocation.Y, Z:=0.0}, NewRotation, (Distance(LerpedLocation, PropTran.Translation) / MovingSpeed))
            

    RotateTowardPlayer(Player: player)<suspends>:void=
        if (Fort := Player.GetFortCharacter[], ThisProp.IsValid[]):
            NewRotation := CalculateRotation(Player)
            ThisProp.MoveTo(ThisProp.GetTransform().Translation, NewRotation, 1.0)


    CalculateRotation(Player: player): rotation =
        if (Fort := Player.GetFortCharacter[], ThisProp.IsValid[]):
            PropLocation := ThisProp.GetTransform().Translation
            PlayerLocation := Fort.GetTransform().Translation

            if (LookDirection := (PlayerLocation - PropLocation).MakeUnitVector[]):
                Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                Roll := 0.0

                NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                return NewRotation
        return rotation{}