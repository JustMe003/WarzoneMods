---@class ProxyObject # Proxy object class
---@field proxyType string # The proxy type
---@field readonly true # Set to true if the object is readonly
---@field readableKeys string[] # The readable keys on this object
---@field writableKeys string[] # The writable keys on this object

---@class Game # The root component containing all the data of the game
---@field Map MapDetails # The root component of the map details
---@field Settings GameSettings # Table containing all the game settings

---@class GameClientHook: Game # The root component that is passed to the client hooks
---@field Us GamePlayer # The data of the client who is playing, is nil when if it is a spectator
---@field Game GameWL # Table containing some public data
---@field LatestStanding GameStanding # The current standing of the game. Can contain fogged territories
---@field GetDistributionStanding fun(callback: fun(standing: GameStanding | nil)) # Used to get the distribution standing of that game. Is nil if the distribution standing is not available
---@field GetStanding fun(turn: integer, callback: fun(standing: GameStanding | nil)) # Pass the turn number and a callback function to retrieve the a GameStanding
---@field GetTurn fun(turn: integer, callback: fun(gameTurn: GameTurn | nil)) # Used to retrieve a GameTurn of a specific turn, pass the turn number and a callback function that takes a GameTurn as argument
---@field Orders GameOrder[] # The order list of the player. Can add, remove and modify any game order
---@field CreateDialog fun(callback: fun(rootParent: RootParent, setMaxSize: fun(width: number, height: number), setScrollable: fun(horizontallyScrollable: boolean, verticallyScrollable: boolean), game: GameClientHook, close: fun())) # Used to create a dialog, arguments are the same arguments that are passed to the Client_PresentMenuUI hook
---@field SendGameCustomMessage fun(waitText: string, payload: table, callback: fun(t: table)) # Used to send updates to the server. Note that it is limited to 5 calls every 5 seconds
---@field HighlightTerritories fun(array: TerritoryID[]) # Used to highlight territories on the map, pass the territoryIDs in an array
---@field CreateLocatorCircle fun(XCoordinate: number, YCoordinate: number) # Pass the X and Y coordinate to create a locater circle on that location

---@class GameServerHook: Game # The root component that is passed to every Server hook
---@field ServerGame ServerGame # The ServerGame object
---@field Game GameWL # Public details of the game

---@class ServerGame: Game # Server game
---@field ActiveTerritoryPicks table<PlayerID, TerritoryID[]> # The territory picks that are currently made by the players
---@field ActiveTurnOrders table<PlayerID, GameOrder[]> # Table containing the orders every committed player has made
---@field CoinCreationFee integer # The amount of coins payed to create this game
---@field CoinEntryFee integer # The amount of coins each player has to pay to play the game
---@field CoinPrize integer # The amount of coins that will be given to the winner(s)
---@field CreatedByAPI boolean # True if the game is created by using the game creation API
---@field CyclicMoveOrder PlayerID[] # The cyclic move order
---@field DistributionStanding GameStanding # The game standing of the distribution turn
---@field Game GameWL # The public details about the game
---@field IsCustomCoinGame boolean # True if the game is a custom coin game
---@field LatestTurnStanding GameStanding # The game standing of the latest turn, updates after every order
---@field PendingStateTransitions PendingStateTransition[] # The array of the pending state transitions
---@field PickOrder PlayerID[] # The order in which picks are processed
---@field PreviousTurnStanding GameStanding # The game standing of the previous turn
---@field RequiredPlayerCount integer | nil # The required number of players
---@field TurnZeroStanding GameStanding # The game standing after the distribution (turn)
---@field SetPlayerResource fun(pid: PlayerID, type: EnumResourceType, newValue: integer) # Sets the player resource to the newValue. Cannot be used in the Server_AdvanceTurn hook

---@class PendingStateTransition # Pending state transitions
---@field NewState EnumGamePlayerState # The new state of the player
---@field PlayerID PlayerID # The ID of the player
---@field TakingOverForAI boolean # True if the player takes over from the AI that has taken its place
---@field TurningIntoAI boolean # True if the player turns into an AI

---@class GamePlayer: ProxyObject # Table containing the data of a player in the game
---@field AIPlayerID PlayerID | nil # The PlayerID of the AI player
---@field AutopilotUsedForNLCFirstTurn boolean # True if the player used AutoPilot for the first turn in a No Luck Cyclic game
---@field BegunFirstTurn DateTime | nil # The DateTime of the time that the player begun their first turn
---@field BootedBy PlayerID | nil # The PlayerID who booted this player
---@field BootedDuration TimeSpan | nil # The duration a player has been booted
---@field Color GameColor # The GameColor of this player
---@field ColorLockedIn boolean # True if the GameColor is locked in when in the lobby
---@field DateInvited DateTime # The DateTime of the date the player was invited to the game
---@field EndedFirstTurn DateTime | nil # The DateTime of when the player ended their first turn
---@field GameID GameID # The identifier of the game
---@field GamePlayerID integer # The unique identifier of the player, only for this game
---@field HasCommittedOrders boolean # True if the player currently has committed their orders
---@field HighestTurnWatched integer # The turn number of the last turn the player has watched
---@field HumanTurnedIntoAI boolean # True if the player turned into an AI player
---@field ID PlayerID # The PlayerID of this player
---@field IsAI boolean # True if the player is an AI player added to the game by the game creator
---@field IsAIOrHumanTurnedIntoAI boolean # True if the player is an AI player, is true if HumanTurnedIntoAI or IsAI is true
---@field LastGameSpeed TimeSpan # The TimeSpan of the speed of the last game
---@field MutePublicChate boolean # True if the player has muted public chat, false otherwise
---@field MuteTeamChate boolean # True if the player has muted team chat, false otherwise
---@field OrdersRevision integer # Not documented
---@field PlayerID PlayerID | nil # The PlayerID of this player
---@field PlayersAcceptedMySurrender table<PlayerID, DateTime> # Table containing the PlayerIDs and DateTimes of the players who accepted this player surrender
---@field PlayersVotedToBoot table<PlayerID, DateTime> # Not documented
---@field ScenarioID integer # Not documented
---@field SeenEndGameWindow boolean # True if the player has seen the end game window
---@field Slot Slot | nil # The Slot this player occupied at the start of the game
---@field SpeedRecordBase DateTime # Not documented
---@field SpeedSamplesForBoot integer[] # Not documented
---@field State EnumGamePlayerState # The State of the player in this game
---@field Surrendered boolean # True if the player has surrendered
---@field Team TeamID # The identifier of the team this player is on. -1 means the player is in no team at all
---@field TimesBooted integer # The amount of times the player has been booted from this game
---@field TimesComeBackFromAI integer # The number of times the player has taken back control after being an AI
---@field TurnSince DateTime # The DateTime of when the last turn advanced and the player was able to create their orders
---@field WasOpenSeat boolean # True if the player joined the game by consuming an open seat
---@field DisplayName fun(standingOpt: GameStanding | nil, includeAIWas: boolean): string # Gets the name of the player, most of the time called with the arguments (nil, false)
---@field Income fun(armiesFromReinforcementCard: integer, standing: GameStanding, bypassArmyCap: boolean, ignoreSanctionCards: boolean): PlayerIncome # Returns the amount of income a player has at the time of the standing

---@class PlayerIncome # Player income
---@field ArmyCapInEffect boolean # True if the player's income was reduced due to the army cap
---@field BonusRestrictions table<BonusID, integer> # Used in a local deployment game, represents the number that can be deployed in a bonus
---@field FreeArmies integer # The number of armies that can be deployed anywhere
---@field Total integer # The total amount of income

---@class GameWL: ProxyObject # Public data about the game
---@field CanBeExportedToYouTube boolean # Set to true if the game can be exported to YouTube
---@field ID GameID # Identifies the game
---@field IsUnevenTeamGame boolean # True if the game uses uneven teams
---@field LastTurnTime DateTime # The DateTime of when the last turn happened
---@field MoveOrderOpt PlayerID[] # Array with the move order of each player
---@field NumberOfLogicalTurns integer # The number of logical turns that have passed
---@field NumberOfTurns integer # The number of turns that have passed
---@field OpenSeatExpirationDate DateTime # The DateTime of when the open seats expire
---@field OpenSeats GameOpenSeat[] # The available open seats
---@field Players table<PlayerID, GamePlayer> # Table containing ALL players, meaning players that are playing, players that are eliminated / booted / surrendered, were invited but declined / got kicked
---@field PlayingPlayers table<PlayerID, GamePlayer> # Table containing only the players left that are playing the game
---@field ServerTime DateTime # The DateTime of the server
---@field Started DateTime # The DateTime of when the game started
---@field StartedDistribution DateTime # The DateTime of when the distribution started
---@field State EnumGameState # The state of the game
---@field TurnNumber integer # The turn number, mostly used when the need is there to read the turn number
---@field VotedToEndGame table<PlayerID, DateTime> # Table containing the players and DateTimes of when the player voted to end the game

---@class GameStanding # A standing in the game
---@field ActiveCards ActiveCard[] # The active cards in this standing
---@field Cards table<PlayerID, PlayerCards> # Table containing all the cards of each player
---@field Territories table<TerritoryID, TerritoryStanding> # Table containing all the TerritoryStandings, identified by the TerritoryID
---@field Resources table<PlayerID, table<EnumResourceType, integer>> # Table containing the resources of each player
---@field IncomeMods IncomeMod[] # Array containing all the income modifications made last turn
---@field NumResources fun(playerID: PlayerID, type: EnumResourceType): integer # Returns the amount of this resource type a player has

---@class TerritoryStanding: ProxyObject # Territory standing
---@field FogLevel EnumStandingFogLevel # How visible the territory is. Note that on the server side this will always be fully visible
---@field ID TerritoryID # Identifier of the territory
---@field IsNeutral boolean # Set to true if the owner is `WL.PlayerID.Neutral`
---@field NumArmies Armies # The Armies that are on this territory
---@field OwnerPlayerID PlayerID # The PlayerID that owns this territory
---@field Structures table<EnumStructureType, integer> | nil # Table containing which structures and with what amount are on this territory

---@class Armies: ProxyObject # The data about the armies
---@field ArmiesOrZero integer # The number of armies on this territory, is 0 if the territory is fogged
---@field AttackPower integer # The total attacking power of the entire Armies object
---@field DefensePower integer # The total defending power of the entire Armies object
---@field Fogged boolean # True when the client cannot see the Armies object
---@field IsEmpty boolean # True if the Armies object has 0 armies and has 0 special units
---@field SpecialUnits SpecialUnit[] # Array containing all the special units in this Armies object
---@field Add fun(armies: Armies): Armies # Combines the 2 Armies object and returns the result. A new Armies object is created and returned
---@field Subtract fun(armies: Armies): Armies # Combines the 2 Armies object and returns the result. A new Armies object is created and returned

---@class SpecialUnit: ProxyObject # Special unit
---@field ID GUID # Identifier of the special unit
---@field OwnerID PlayerID # The owner of the special unit

---@class Commander: SpecialUnit # Commander unit
---@field CombatOrder `10000` # The CombatOrder of the commander

---@class Boss1: SpecialUnit # Boss1 unit
---@field Health integer # The amount of healt points remaining for this unit
---@field CombatOrder `4000` # The CombatOrder of the unit

---@class Boss2: SpecialUnit # Boss2 unit
---@field Power integer # The power of this unit
---@field Stage integer # The stage of this unit
---@field CombatOrder `4001` # The CombatOrder of the unit

---@class Boss3: SpecialUnit # Boss3 unit
---@field Power integer # The power of this unit
---@field Stage integer # The stage of this unit
---@field CombatOrder `4002` # The CombatOrder of the unit

---@class Boss4: SpecialUnit # Boss4 unit
---@field Health integer # The amount of healt points remaining for this unit
---@field Power integer # The power of this unit
---@field CombatOrder `4004` # The CombatOrder of the unit

---@class CustomSpecialUnitClass: ProxyObject # Custom special unit fields
---@field AttackPower integer # The number it adds to the total attack power of the Armies object it is part of
---@field AttackPowerPercentage number # Attacks that include this unit have their power multiplied by this number. `1.0` means nothing happens, `2.0` means that the power is doubled (+100%) and `0.5` means the power if halved (-50%)
---@field CanBeAirliftedToSelf boolean # If true this unit can be airlifted from and to a territory that is owned by the player who also owns this unit
---@field CanBeAirliftedToTeammate boolean # If true this unit can be airlifted from and to a territory that is owned by the player or a teammate
---@field CanBeGiftedWithGiftCard boolean # If true a territory with this unit can be gifted to another player. If false a territory with this unit cannot be gifted
---@field CanBeTransferredToTeammate boolean # If true this unit can be transferred to a territory controlled by a teammate
---@field CombatOrder integer # The combat order determines the order in which special units take damage. The higher the CombatOrder, the later this unit will take damage
---@field DamageAbsorbedWhenAttacked integer # When this unit takes damage, it will reduce the amount of damage remaining to other units by this value, has no effect if the unit has a Health
---@field DamageToKill integer # The amount of damage is needed to kill this unit. This must be done in one attack and this field has no effect if the unit has a Health
---@field DefensePower integer # The number it adds to the total defence power of the Armies object it is part of
---@field DefensePowerPercentage integer # When this unit defends from an attack, the total defence power is multiplied by this number. `1.0` means nothing happens, `2.0` means that the power is doubled (+100%) and `0.5` means the power if halved (-50%)
---@field Health integer | nil # Defines the health of the unit. When nil the DamageToKill is used to determine when this unit dies. The unit will automatically reduce health when it takes damage and is removed when it's health is below 1
---@field ImageFileName string # The name of the PNG file in the `SpecialUnitsImages` folder. This will be the icon of the unit that is shown on the map
---@field IncludeABeforeName boolean # If true, when displaying this units name an 'A' will be put before the name
---@field IsVisibleToAllPlayers boolean # If true, this unit is at all times visible for all players, meaning that a territory with this unit will be visible for every player in the game
---@field ModData string # Custom data added to the unit. Please note that using the ID of the unit to save data in one of the Mod storages is not safe since it is fairly common to clone a unit, modify where necessary, remove the old unit and add the clone back. This results in essentially the same unit but with a different ID. 
---@field ModID ModID | nil # The ID of the mod that created this unit
---@field Name string # The name of the unit. Note that this field is not used to display text on the map
---@field TextOverHeadOpt string # A string that will appear above the unit on the map. Recommended to not use long string, but keep it short (8 characters max)

---@class CustomSpecialUnit: CustomSpecialUnitClass, SpecialUnit # Custom special unit

---@class GameTurn # A game turn
---@field MoveOrder PlayerID[] # The move order in this turn
---@field Orders GameOrder[] # The complete order list of the turn, note that a client will only see the orders it was able to see
---@field TurnNumber integer # The number of the turn
---@field TurnTime DateTime # The DateTime of when the turn happened

---@class GameOrder: ProxyObject # Base class of all orders
---@field OccursInPhase EnumTurnPhase | nil # The phase in which the order will be played. Note that orders added in the `Server_AdvanceTurn_*` hook are played immediately, ignoring this field
---@field PlayerID PlayerID # The ID of the player to whom this order belongs to
---@field ResultObj GameOrderResult # The result object of the order
---@field ResultsKnown boolean # True if the results of this order are known
---@field StandingUpdates TerritoryStanding[] # The new territoryStandings that were modified by this order

---@class GameOrderPlayCard: GameOrder # Base class for orders for cards
---@field CardID CardID # The ID of the card played in this order
---@field CardInstanceID CardInstanceID # The CardInstanceID of the card that is played in this turn

---@class GameOrderPlayCardAirlift: GameOrderPlayCard # Game order for playing an airlift card
---@field Armies Armies # The Armies object that is airlifted
---@field FromTerritoryID TerritoryID # The territory where the armies are moved away from
---@field Result GameOrderPlayCardAirliftResult # The result object of the order
---@field ToTerritoryID TerritoryID # The territory where the armies are moved to

---@class GameOrderPlayCardReinforcement: GameOrderPlayCard # Game order for playing a reinforcement card

---@class GameOrderPlayCardSpy: GameOrderPlayCard # Game order for playing a spy card
---@field TargetPlayerID PlayerID # The player on which will be spyed on

---@class GameOrderPlayCardAbandon: GameOrderPlayCard # Game order for playing a emergency blockade card
---@field TargetTerritoryID TerritoryID # The ID of the territory that will be blockaded

---@class GameOrderPlayCardOrderPriority: GameOrderPlayCard # Game order for playing an order priority card

---@class GameOrderPlayCardOrderDelay: GameOrderPlayCard # Game order for playing an order delay card

---@class GameOrderPlayCardGift: GameOrderPlayCard # Game order for playing a gift card
---@field GiftTo PlayerID # The player that will receive the territory
---@field TerritoryID TerritoryID # The territory that will be gifted

---@class GameOrderPlayCardDiplomacy: GameOrderPlayCard # Game order for playing a diplomacy card
---@field PlayerOne PlayerID # The first player
---@field PlayerTwo PlayerID # The second player

---@class GameOrderPlayCardSanctions: GameOrderPlayCard # Game order for playing a sanctions card
---@field SanctionedPlayerID PlayerID # The ID of the sanctioned player

---@class GameOrderPlayCardReconnaissance: GameOrderPlayCard # Game order for playing a reconnaissance card
---@field TargetTerritory TerritoryID # The ID of the territory that (and its neighbours) will be visible

---@class GameOrderPlayCardSurveillance: GameOrderPlayCard # Game order for playing a surveillance card
---@field TargetBonus BonusID # The ID of the selected bonus

---@class GameOrderPlayCardBlockade: GameOrderPlayCard # Game order for playing a blockade card
---@field TargetTerritoryID TerritoryID # The ID of the territory that will be blockaded

---@class GameOrderPlayCardBomb: GameOrderPlayCard # Game order for playing a bomb card
---@field TargetTerritoryID TerritoryID # The ID of the territory that will be bombed

---@class GameOrderAttackTransfer: GameOrder # Game order for attacking and / or transfering
---@field AttackTeammates boolean # Set to true if the order will attack teammates
---@field AttackTransfer EnumAttackTransfer # The type of the order
---@field ByPercent boolean # Set to true if the number of normal armies will be interpreted as an percentage
---@field From TerritoryID # The ID of the territory where the order is from
---@field NumArmies Armies # The armies parttaking in the order
---@field Result GameOrderAttackTransferResult # The result of the order
---@field To TerritoryID # The ID of the territory where the order will go to

---@class GameOrderDeploy: GameOrder # Game order for deploying
---@field DeployOn TerritoryID # The ID of the territory that will be deployed on
---@field NumArmies integer # The number of armies that will be added
---@field Free boolean # If true, and the game is a commerce game, then the player will not be charged gold for this deployment

---@class GameOrderStateTransition: GameOrder # Game order for state transitions
---@field NewState EnumGamePlayerState # The new state of the player
---@field TakingOverForAI boolean # True if the player takes over from the AI that had taken their place
---@field TurningIntoAI boolean # True if the player turns into an AI

---@class GameOrderReceiveCard: GameOrder # Game order for receiving cards, should never be sent from a client
---@field CardIDs table<CardID, integer> # Table containing the CardIDs and number of pieces for each card
---@field InstancesCreated CardInstance[] # Array containing all the card instances that were created

---@class ActiveCardWoreOff: GameOrder # Game order for active cards wearing off
---@field Card GameOrderPlayCard # The order that originally added the order

---@class GameOrderDiscard: GameOrder # Game order for discarding cards
---@field CardInstanceID CardInstanceID # The card instance ID of the card being discarded

---@class GameOrderPlayCardFogged: GameOrder # Game order for playing cards that are fogged
---@field CardInstanceID CardInstanceID # The card instance ID of the card that is played

---@class GameOrderBossEvent: GameOrder # Game order for boss events
---@field BossIndex integer # Not documented
---@field modifyTerritories TerritoryModification[] # The array of territory modifications
---@field SpecialUnitID GUID # The GUID of the unit

---@class GameOrderEvent: GameOrder # Game order for events
---@field Message string # The message that will show up in the order list when the order is played
---@field TerritoryModifications TerritoryModification[] # The array containing all the territory modifications
---@field VisibleToOpt HashSet<PlayerID> # HashSet of PlayerIDs of those who are able to see the order
---@field SetResourceOpt table<PlayerID, table<EnumResourceType, integer>> # (Please use `AddResourceOpt` instead of this field!). Table containing the new resources for each player, overriding the old data
---@field IncomeMods IncomeMod[] # Array of income modifications
---@field AddResourceOpt table<PlayerID, table<EnumResourceType, integer>> # Table containing all the added or removed resources for each player
---@field AddCardPiecesOpt table<PlayerID, table<CardID, integer>> # The amount of card pieces that are added of each card for each player
---@field RemoveWholeCardsOpt table<PlayerID, CardInstanceID> # Removes whole cards from a player
---@field JumpToActionSpotOpt RectangleVM | nil # Makes the client view jump to the given RectangleVM
---@field ModID ModID | nil # The ID of the mod who created this order

---@class GameOrderCustom: GameOrder # Custom game order, mostly used for creating custom client orders that are processed into GameOrderEvents on the server side
---@field Message string # The message that appear in the order list
---@field Payload string # Data send with the order in a string
---@field CostOpt table<EnumResourceType, integer> # The cost of the order
---@field OccursInPhase EnumTurnPhase | integer | nil # The phase in which this order will be processed. Note that when you create a GameOrderCustom and set this field, you must add the order in the order list in the right place

---@class GameOrderPurchase: GameOrder # Game order for purchasing
---@field BuildCities table<TerritoryID, integer> # Table containing each territory ID where a city will be built and the amount of cities for that territory

---@class GameOrderResult # Base class of a game order result

---@class GameOrderAttackTransferResult: GameOrderResult # The result of a GameOrderAttackTransfer
---@field ActualArmies Armies # The actual armies that participated in the attack / transfer
---@field AttackingArmiesKilled Armies # The armies that are killed on the attacking side
---@field DamageToSpecialUnits table<GUID, integer> # The damage done to special units, only when they are not killed
---@field DefendingArmieskilled Armies # The armies that are killed on the defending side
---@field DefenseLuck number | nil # The luck attribute for the defending player
---@field IsAttack boolean # True if the attack / transfer was an attack
---@field IsNullified boolean # True if the attack is nullified, essentially skipping the order
---@field IsSuccessful boolean # True if the attack / transfer was able to reach the other territory, if IsAttack is also true the order successfully took the defending territory
---@field OffenseLuck number | nil # The luck attribute for the attacking player

---@class GameOrderDeployResult: GameOrderResult # Result of a GameOrderDeploy

---@class GameOrderStateTransitionResult: GameOrderResult # Result of a GameOrderStateTransition

---@class GameOrderReceiveCardResult: GameOrderResult # Result of a GameOrderReceiveCard

---@class ActiveCardWoreOffResult: GameOrderResult # Result of a ActiveCardWoreOff

---@class GameOrderDiscardResult: GameOrderResult # Result of a GameOrderDiscard

---@class GameOrderPlayCardFoggedResult: GameOrderResult # Result of a GameOrderPlayCardFogged

---@class GameOrderBossEventResult: GameOrderResult # Result of a GameOrderBossEvent

---@class GameOrderEventResult: GameOrderResult # Result of a GameOrderEvent
---@field CardInstancesCreated CardInstance[] # The card instances created as a result of this GameOrderEvent

---@class GameOrderCustomResult: GameOrderResult # Result of a GameOrderCustom

---@class GameOrderPurchaseResult: GameOrderResult # Result of a GameOrderPurchase

---@class GameOrderPlayCardResult: GameOrderResult # Result of a GameOrderPlayCard

---@class GameOrderPlayCardAirliftResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardAirlift
---@field ActualArmies integer # Not documented
---@field ArmiesAirlifted Armies | nil # The armies object that is airlifted or nil

---@class GameOrderPlayCardReinforcementResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardReinforcement

---@class GameOrderPlayCardSpyResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardSpy

---@class GameOrderPlayCardAbandonResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardAbandon

---@class GameOrderPlayCardOrderPriorityResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardOrderPriority

---@class GameOrderPlayCardOrderDelayResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardOrderDelay

---@class GameOrderPlayCardGiftResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardGift

---@class GameOrderPlayCardDiplomacyResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardDiplomacy

---@class GameOrderPlayCardSanctionsResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardSanctions

---@class GameOrderPlayCardReconnaissanceResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardReconnaissance

---@class GameOrderPlayCardSurveillanceResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardSurveillance

---@class GameOrderPlayCardBlockadeResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardBlockade

---@class GameOrderPlayCardBombResult: GameOrderPlayCardResult # Result of a GameOrderPlayCardBomb

---@class TerritoryModification # Territory modification
---@field TerritoryID TerritoryID # The ID of the territory for this territory modification
---@field AddSpecialUnits SpecialUnit[] | nil # The special units that will be added to this territory
---@field SetArmiesTo integer | nil # Overrides the amount of armies to this number, it is recommended to use AddArmies instead
---@field AddArmies integer | nil # Adds or removes this amount of armies
---@field SetOwnerOpt PlayerID | nil # The new owner of this territory
---@field SetStructuresOpt table<EnumStructureType, integer> # Set the amount of structures on this territory. Recommended to use the AddStructuresOpt field
---@field AddStructuresOpt table<EnumStructureType, integer> # Adds or removes the amount of structures on this territory
---@field RemoveSpecialUnitsOpt HashSet<GUID> # The units that will be removed from this territory

---@class IncomeMod: ProxyObject # An income modification
---@field Message string # The string that will be displayed in the income breakdown menu
---@field Mod integer # The amount of income added or removed
---@field PlayerID PlayerID # The ID of the player of which this income modification is
---@field BonusID BonusID | nil # If set, the income of this can only be deployed in this bonus

---@class RectangleVM # Represents a rectangle by 4 coordinates
---@field Bottom number # The coordinate of the bottom side
---@field Left number # The coordinate of the left side
---@field Right number # The coordinate of the right side
---@field Top number # The coordinate of the top side

---@class ActiveCard: ProxyObject # Active card
---@field Card GameOrderPlayCard # The order that made the card active
---@field ExpiresAfterTurn integer # The turn number after the card will expire
---@field ExpiresAfterTurnForDisplay integer # The turn number after the card will expire that will be displayed

---@class PlayerCards: ProxyObject # Cards data owned by a player
---@field ID PlayerID # The PlayerID
---@field Pieces table<CardID, integer> # The number of card pieces (full cards not counted) the player owns
---@field PlayerID PlayerID # The PlayerID
---@field WholeCards table<CardInstanceID, CardInstance> # Table with all the whole cards that the player owns

---@class CardInstance: ProxyObject # Instance of an actual card that is playable with an GameOrderPlayCard
---@field CardID CardID # The CardID of the instance
---@field ID CardInstanceID # The CardInstanceID of the instance

---@class NoParameterCardInstance: CardInstance # Used for creating a card instance for any card except a reinforcement card

---@class ReinforcementCardInstance: CardInstance # Used for creating a card instance for a reinforcement card
---@field Armies integer # The amount of armies this card gives

---@class GameColor: ProxyObject # The GameColor
---@field A integer # Alpha (opacity, RGBA) value of the color
---@field B integer # Blue (RGBA) value of the color
---@field G integer # Green (RGBA) value of the color
---@field HtmlColor string # Hexadecimal string with the format "#XXXXXX"
---@field Index integer # Not documented
---@field IntColor integer # Not documented
---@field IsBaseColor boolean # Not documented
---@field IsReservedColor boolean # Not documented
---@field Name string # Name of the color
---@field R integer # Red (RGBA) value of the color

---@class GameOpenSeat # An open seat
---@field OpenSeatID integer # The identifier of the open seat
---@field Slot Slot | nil # The Slot that the player who takes this open seat will occupy
---@field Team TeamID # The TeamID of the team that the player who takes this open seat will be part of

---@class MapDetails: ProxyObject # The root component containing all the map details of the map the game is being played on
---@field Bonuses table<BonusID, BonusDetails> # Table containing all the BonusDetails of the map, indexed by BonusID
---@field CreatedOn DateTime # The DateTime of when the map was created
---@field DefaultDistributionMode DistributionID # The default distribution mode set by the map creator
---@field DistributionModes table<DistributionID, DistributionMode> # Table containing all custom distribution modes
---@field FamilyForClient MapFamily # The collection of all versions of this map
---@field FamilyID MapFamilyID # The identifier used to identify the MapFamily
---@field ID MapID # The identifier used to identify this map
---@field LastModified DateTime # The DateTime of when the map was last modified
---@field Territories table<TerritoryID, TerritoryDetails> # Table containing all the TerritoryDetails of the map, indexed by TerritoryID
---@field IsBigMapFor3d boolean # Not documented
---@field OverrideIsBigMapFor3d boolean | nil # Not documented

---@class GameSettings # Table containing all the game settings of this game
---@field AIsSurrenderWhenOneHumanRemains boolean # If true, AIs surrender when there's only 1 human left
---@field AllowAttackOnly boolean # Allows move orders to be set to attack only
---@field AllowPercentageAttacks boolean # Allows attacking with a percentage amount of armies
---@field AllowTransferOnly boolean # Allows move orders to be set to transfer only
---@field AllowVacations boolean # Honor vacation
---@field ArmyCap number | nil # Defines how much armies a player can have at most; ArmyCap * Income
---@field AtStartDivideIntoTeamsOf integer # Defines in how many teams the players are split when the game starts
---@field AutoBootEnabled boolean # Players are automatically booted if true
---@field AutoBootTime TimeSpan # The number of seconds the game will wait till auto booting a player
---@field AutoForceJoinTime TimeSpan # Not documented
---@field AutomaticTerritoryDistribution boolean # If true, the game is a automatic distribution, otherwise a manual distribution
---@field AutoStartGame boolean # Used to auto start a game
---@field BankDuration integer # The amount of time players have banked
---@field BankingBootTimes integer | nil # The banking boot times
---@field BonusArmyPer integer # Players get extra income by `floor(territories controlled / BonusArmyPer)`
---@field BootedPlayersTurnIntoAIs boolean # Players that are booted are turned into AIs
---@field CardHoldingsAndReceivesFogged boolean # determines whether everyone can see who holds and receives which cards
---@field CardPlayingsFogged boolean # Only show players the order of playing a card if they can see the effects of it
---@field Cards table<CardID, CardGame> # Table containing all the cards and their settings
---@field CoinEntryFee integer # The amount of coins a player must pay to play the game
---@field CoinPrize integer # The amount of coins the player will win
---@field Commanders boolean # If true, every player starts with a commander, otherwise the game does not automatically give every player a commander. Note that mods can still give players commanders
---@field CommerceArmyCostMultiplier integer | nil # If not null and CommerceGame is true, deploying armies in the same turn will get more and more expensive
---@field CommerceCityBaseCost integer | nil # If not null and CommerceGame is true, this is the base cost to build a city
---@field CommerceGame boolean # Defines whether the game uses gold or armies as currency
---@field Created DateTime # The DateTime of when the game was created
---@field CustomScenario CustomScenario # The custom scenario the game uses
---@field DefenseKillRate number # The defensive kill rate
---@field DirectBootTime TimeSpan # Not documented
---@field DirectBootTimeSummaryString string # Not documented
---@field DistributionModeID DistributionID # Defines which distribution is used
---@field FogLevel EnumGameFogLevel # Defines which fog level is used
---@field ForceJoinTime TimeSpan # Not documented
---@field HasAnySortOfFog boolean # Set to true if the game uses some sort of fog, false if the game uses NoFog
---@field HasSpecialUnits boolean # Set to true if the game has any type of special unit
---@field InitialBank TimeSpan # The amount of time the players have banked at the start of the game
---@field InitialNeutralsInDistribution integer # The amount of armies that will be placed on territories that were in the distribution
---@field InitialNonDistributionArmies integer # The amount of armies that will be placed on territories that were not in the distribution
---@field InitialPlayerArmiesPerTerritory integer # The amount of armies that will be placed on territories that were assigned to players
---@field InstantSurrender boolean # Defines whether a player has to receive permission from every player to surrender or not
---@field IsArchived boolean # Defines whether the game is archived or not
---@field IsCoinsGame boolean # Set to true if the game is a coin game
---@field IsTournamentLadderQuickmatchOrClanWar boolean # Set to true if the game is a tournament, ladder, quickmatch or clan war game
---@field KillRatesAreModified boolean # Set to true if the kill rates are modified
---@field LadderID LadderID | nil # Defines from which ladder this game is from
---@field LimitDistributionTerritories integer # The maximum amount of territories a player can end up with after the distribution
---@field LocalDeployments boolean # Set to true if the game ues local deployments
---@field LuckModifier number # The modifier used to determine the outcome of an attack order
---@field MapID MapID # The MapID of the map that is used
---@field MapTestingGame boolean # Set to true if the map is being tested
---@field MaxCardsHold integer # The maximum amount of cards a player can hold
---@field MinimumArmyBonus integer # The minimum amount of income a player has
---@field MinimumBootTime TimeSpan # The minimum amount of time until a player can be booted
---@field MinimumVersionRequired integer # Clients need to play on a version that is equal or higher than this setting
---@field MoveOrder EnumMoveOrder # The type of MoveOrder which is used
---@field MultiAttack boolean # Allows players to attack multiple times with an army
---@field MultiPlayer boolean # Set to true if the game is a multiplayer game, set to false if the game is a singleplayer game
---@field Name string # The name of the game
---@field NoSplit boolean # Set to true if the game uses NoSplit
---@field NumberOfCardsToReceiveEachTurn integer # The number of cards each player recieves each turn
---@field NumberOfWastelands integer # The number of wastelands in the game
---@field OffenseKillRate number # The offensive kill rate
---@field OneArmyMustStandGuardOneOrZero integer # Not documented
---@field OneArmyStandsGuard boolean # Set to true if a territory needs 1 army at all times
---@field OverriddenBonuses table<BonusID, integer> # Table containing all overridden bonus values, indexed by their BonusID
---@field PersonalMessage string # The personal message of the game creator
---@field PrivateMessaging boolean # Allow players to private message eachother in the game
---@field RankedGame boolean # Defines whether the game is a practice or a ranked game
---@field RealTimeGame boolean # Set to true if the game is a RT (real time) game, false if the game is a MD (multi day) game
---@field RoundingMode RoundingModeEnum # The rounding mode used for this game
---@field SinglePlayer boolean # Set to true if the game is a singleplayer game
---@field StartedBy PlayerID | nil # The player that started the game, or nil if the game was automatically started
---@field StartedByInfo PlayerInfo2 # Some data of the player that started the game
---@field SurrenderedPlayersTurnIntoAIs boolean # Set to true if players that surrender turn into an AI
---@field TemplateIDUsed TemplateID | nil # The TemplateID of which the game was created or nil if the game was not created from a template
---@field TemplateName string # The name of the template
---@field TimesCanComeBackFromAI integer # The amount of times a player can come back from being turned into an AI
---@field TournamentID integer | nil # The ID of the tournament if the game is a tournament game, nil if the game is not a tournament game
---@field VoteBootTime TimeSpan # Not documented
---@field WastelandSize integer # The amount of armies on a wasteland territory at the start of the game

---@class BonusDetails: ProxyObject # Table containing the details of a bonus
---@field Amount integer # The default amount of armies the bonus will give when fully controlled by one player
---@field Color integer[] # The color codes in which the bonus is shows on the map
---@field ID BonusID # The identifier used to identify this bonus
---@field Name string # The name of the bonus
---@field Territories TerritoryID[] # The array of territories of which this bonus consists of

---@class DistributionMode # A custom distribution mode, created by the game creator
---@field Description string # A description of the distribution mode
---@field ID DistributionID # The identifier used to identify this distribution
---@field Name string # The name of the distribution

---@class MapFamily: ProxyObject # A collection that represents all versions of a single map
---@field Category MapCategory # The category under which this map can be found
---@field CreatedBy PlayerID # The PlayerID of the player who created the MapFamily
---@field CreatedOn DateTime # The DateTime of when the MapFamily was created
---@field DateMadePublic DateTime | nil # The DateTime of when the MapFamily was made public or nil of the MapFamily is not public
---@field DateLastCleaned DateTime | nil # Not documented
---@field Description string # The description of the MapFamily
---@field ID MapFamilyID # The identifier used to identify this MapFamily
---@field LastModified DateTime # The DateTime of when the map was last modified
---@field Name string # The name of the map
---@field Tags string[] | nil # The tags of the map
---@field UnlockLevel integer # The level of which a player must be to unluck this map

---@class TerritoryDetails: ProxyObject # Table containing the details of a territory
---@field ConnectedTo table<TerritoryID, TerritoryConnection> # Table containing all the territories and connection types that are connected to this territory
---@field ID TerritoryID # The identifier used to identify this territory
---@field MiddlePointX number # The X coordinate of where on on the map this territory is
---@field MiddlePointY number # The Y coordinate of where on on the map this territory is
---@field Name string # The name of the territory
---@field PartOfBonuses BonusID[] # Array containing all the bonuses this territory is part of

---@class TerritoryConnection: ProxyObject # Table containing the connection data
---@field ID TerritoryID # The TerritoryID which is connected with this connection
---@field Wrap EnumTerritoryConnectionWrap # The enum type of connection

---@class CardGame # Settings of a card in the game, abstract type
---@field ActiveCardExpireBehavior ActiveCardExpireBehaviorOptions # The behaviour when the card expires
---@field ActiveOrderDuration integer # The amount of turns this card is active
---@field CardID CardID # The identifier used to identify this CardGame
---@field Description string # The description of the card
---@field FriendlyDescription string # The Friendly description of the card
---@field ID CardID # The identifier used to identify this CardGame
---@field InitialPieces integer # The amount of card pieces each player starts with
---@field IsStoredInActiveOrders boolean # Set to tru if it is stored in active orders
---@field MinimumPiecesPerTurn integer # The amount of pieces each player receives per turn
---@field NumPieces integer # The amount of pieces that turns the card into a whole card
---@field Weight number # The weight of the card when picking cards randomly

---@class CardGameAbandon: CardGame # Emergency Blockade card. Named "Abandon" for historical reasons
---@field MultiplyAmount number # The multiplier used to multiply the amount of armies on the territory
---@field MultiplyPercentage string # The percentage string of the multiplier

---@class CardGameAirlift: CardGame # Airlift card

---@class CardGameBlockade: CardGame # Blockade card
---@field MultiplyAmount number # The multiplier used to multiply the amount of armies on the territory
---@field MultiplyPercentage string # The percentage string of the multiplier

---@class CardGameBomb: CardGame # Bomb card

---@class CardGameDiplomacy: CardGame # Diplomacy card
---@field Duration integer # The amount of turns a diplomacy will last

---@class CardGameGift: CardGame # Gift card

---@class CardGameOrderDelay: CardGame # Order delay card

---@class CardGameOrderPriority: CardGame # Order priority card

---@class CardGameReconnaissance: CardGame # Reconnaissance card
---@field Duration integer # The amount of turns a reconnaissance card will last

---@class CardGameReinforcement: CardGame # Reinforcement card
---@field Fixed integer # Integer representing the fixed amount of armies
---@field Mode EnumReinforcementCardMode # The mode of the reinforcement card
---@field ProgressivePercentage number # The progressive percentage of the reinforcement card

---@class CardGameSanctions: CardGame # Sanctions card
---@field Duration integer # The duration of the sanctions card
---@field Percentage number # The percentage that will be subtracted from the income
---@field PercentString string # The percentage as a string

---@class CardGameSpy: CardGame # Spy card
---@field CanSpyOnNeutral boolean # Set to true if players are allowed to spy on neutral
---@field Duration integer # The duration of the spy card

---@class CardGameSurveillance: CardGame # Surveillance card
---@field Duration integer # The duration of the surveillance card

---@class CustomScenario # Custom scenario
---@field SlotsAvailable Slot[] # The slots that are available
---@field Territories table<TerritoryID, CustomScenarioTerritory> # Table containing all the custom scenario territory data, indexed by TerritoryID

---@class CustomScenarioTerritory # Custom scenario territory data
---@field InitialArmies integer # The amount of armies that this territory will start with
---@field Slot Slot | nil # The slot that this territory is assigned to or nil if the territory is not assigned to any slot
---@field SpecialUnits SpecialUnit[] # Array containing all the special units on this territory
---@field TerritoryID TerritoryID # The TerritoryID that identifies this territory

---@class PlayerInfo2 # Public information about a player
---@field ClanOpt ClanPlayerInfo # The clan data of the player
---@field IsMember boolean # True if the player has a membership
---@field Level integer # The level of this player
---@field Name string # The name of the player

---@class ClanPlayerInfo # The clan data
---@field ClanID ClanID # The ID that identifies this clan
---@field IconIncre integer # Not documented
---@field Name string # The name of the clan 


---@alias TerritoryID integer # The identifier used to uniquely identify territories
---@alias BonusID integer # The identifier used to uniquely identify bonuses
---@alias DateTime string # A string of the format "yyyy-MM-dd HH:mm:ss:fff" in GMT timezone
---@alias DistributionID integer # The identifier used to uniquely identify distributions
---@alias MapFamilyID integer # The identifier used to uniquely identify map families
---@alias PlayerID EnumPlayerID | integer # The identifier used to uniquely identify the player controlling the territory
---@alias MapCategory any # Not documented
---@alias MapID integer # The identifier used to uniquely identify maps
---@alias TimeSpan number # A number representing time in seconds
---@alias CardID integer # The identifier used to uniquely identify cards
---@alias Slot integer # Integer that represents a slot in a custom scenario
---@alias LadderID integer # Identifier that identifies a ladder
---@alias ClanID integer # Identifier that identifies a clan
---@alias TemplateID integer # Identifier that identifies a template
---@alias GameID integer # Identifier that uniquely identifies a Game
---@alias TeamID integer # Identifies which team a player is on, `-1` means that the player is on no team
---@alias CardInstanceID string # Identifies a card, is a GUID
---@alias GUID string # GUID string for identification purposes
---@alias Enum integer # Enum value, you should not know this value but use the right field in `WL`
---@alias ModID integer # The identifier that uniquely identifies a mod

---@class HashSet<T>: { [integer]: T} # Array of type T, must not contain duplicates



---@class WL # Table containing all enum values and create functions
---@field PlayerID EnumPlayerID # The table containing all PlayerID enums
---@field TerritoryConnectionWrap EnumTerritoryConnectionWrap # The table containing all the TerritoryConnectionWrap enums
---@field CustomSpecialUnitBuilder CustomSpecialUnitBuilder # Builder to create a CustomSpecialUnit
---@field GamePlayerState EnumGamePlayerState # Available player state enums
---@field GameState EnumGameState # Available game state enums
---@field StandingFogLevel EnumStandingFogLevel # Available game state enums
---@field GameFogLevel EnumGameFogLevel # Available game state enums
---@field StructureType EnumStructureType # Available structure type enums
---@field MoveOrder EnumMoveOrder # Available move order enums
---@field RoundingMode RoundingModeEnum # Available rounding mode enums
---@field ActiveCardExpireBehaviorOptions ActiveCardExpireBehaviorOptions # Available active card expire behaviour enums
---@field ReinforcementCardMode EnumReinforcementCardMode # Available reinforcement card mode enums
---@field TurnPhase EnumTurnPhase # Available turn phase enums
---@field AttackTransferEnum EnumAttackTransfer # Available attack / transfer enums
---@field ResourceType EnumResourceType # Available resource type enums
---@field Armies ArmiesWL # Allows for creating Armies objects
---@field Boss1 Boss1WL # Allows for creating Boss1 objects
---@field Boss2 Boss2WL # Allows for creating Boss1 objects
---@field Boss3 Boss3WL # Allows for creating Boss1 objects
---@field Boss4 Boss4WL # Allows for creating Boss1 objects
---@field Commander CommanderWL # Allows for creating Commander objects
---@field CardGameAbandon CardGameAbandonWL # Allows for creating CardGameAbandon objects
---@field CardGameAirlift CardGameAirliftWL # Allows for creating CardGameAirlift objects
---@field CardGameBlockade CardGameBlockadeWL # Allows for creating CardGameAirlift objects
---@field CardGameBomb CardGameBombWL # Allows for creating CardGameBomb objects
---@field CardGameDiplomacy CardGameDiplomacyWL # Allows for creating CardGameDiplomacy objects
---@field CardGameGift CardGameGiftWL # Allows for creating CardGameGift objects
---@field CardGameOrderDelay CardGameOrderDelayWL # Allows for creating CardGameOrderDelay objects
---@field CardGameOrderPriority CardGameOrderPriorityWL # Allows for creating CardGameOrderPriority objects
---@field CardGameReconnaissance CardGameReconnaissanceWL # Allows for creating CardGameReconnaissance objects
---@field CardGameReinforcement CardGameReinforcementWL # Allows for creating CardGameReinforcement objects
---@field CardGameSanctions CardGameSanctionsWL # Allows for creating CardGameSanctions objects
---@field CardGameSpy CardGameSpyWL # Allows for creating CardGameSanctions objects
---@field CardGameSurveillance CardGameSurveillanceWL # Allows for creating CardGameSurveillance objects
---@field NoParameterCardInstance NoParameterCardInstanceWL # Allows for creating NoParameterCardInstance objects
---@field ReinforcementCardInstance ReinforcementCardInstanceWL # Allows for creating ReinforcementCardInstance objects
---@field CustomScenario CustomScenarioWL # Allows for creating CustomScenario objects
---@field GameOrderAttackTransfer GameOrderAttackTransferWL # Allows for creating GameOrderAttackTransfer objects
---@field GameOrderCustom GameOrderCustomWL # Allows for creating GameOrderCustom objects
---@field GameOrderDeploy GameOrderDeployWL # Allows for creating GameOrderDeploy objects
---@field GameOrderDiscard GameOrderDiscardWL # Allows for creating GameOrderDiscard objects
---@field GameOrderEvent GameOrderEventWL # Allows for creating GameOrderEvent objects
---@field GameOrderPlayCardAbandon GameOrderPlayCardAbandonWL # Allows for creating GameOrderPlayCardAbandon objects
---@field GameOrderPlayCardAirlift GameOrderPlayCardAirliftWL # Allows for creating GameOrderPlayCardAirlift objects
---@field GameOrderPlayCardBlockade GameOrderPlayCardBlockadeWL # Allows for creating GameOrderPlayCardBlockade objects
---@field GameOrderPlayCardBomb GameOrderPlayCardBombWL # Allows for creating GameOrderPlayCardBomb objects
---@field GameOrderPlayCardDiplomacy GameOrderPlayCardDiplomacyWL # Allows for creating GameOrderPlayCardDiplomacy objects
---@field GameOrderPlayCardGift GameOrderPlayCardGiftWL # Allows for creating GameOrderPlayCardGift objects
---@field GameOrderPlayCardOrderDelay GameOrderPlayCardOrderDelay # Allows for creating GameOrderPlayCardOrderDelay objects
---@field GameOrderPlayCardOrderPriority GameOrderPlayCardOrderPriorityWL # Allows for creating GameOrderPlayCardOrderPriority objects
---@field GameOrderPlayCardReconnaissance GameOrderPlayCardReconnaissanceWL # Allows for creating GameOrderPlayCardReconnaissance objects
---@field GameOrderPlayCardReinforcement GameOrderPlayCardReinforcementWL # Allows for creating GameOrderPlayCardReinforcement objects
---@field GameOrderPlayCardSanctions GameOrderPlayCardSanctionsWL # Allows for creating GameOrderPlayCardSanctions objects
---@field GameOrderPlayCardSpy GameOrderPlayCardSpyWL # Allows for creating GameOrderPlayCardSpy objects
---@field GameOrderPlayCardSurveillance GameOrderPlayCardSurveillanceWL # Allows for creating GameOrderPlayCardSurveillance objects
---@field GameOrderReceiveCard GameOrderReceiveCardWL # Allows for creating GameOrderReceiveCard objects
---@field IncomeMod IncomeModWL # Allows for creating IncomeMod objects
---@field IsVersionOrHigher fun(version: string): boolean # Returns whether the client uses the version or a higher version than the one provided
---@field PlayerCards PlayerCardsWL # Allows for creating PlayerCards objects
---@field TerritoryModification TerritoryModificationWL # Allows for creating TerritoryModification objects
---@field TickCount fun(): integer # The amount of time in miliseconds have passed, useful for profiling code
---@field ModOrderControl EnumModOrderControl # Available ModOrderControl enums

---@class EnumPlayerID # 
---| 'Neutral' # The PlayerID representing a neutral territory
---| 'Fog' # The PlayerID representing a fogged territory
---| 'AvailableForDistribution' # The PlayerID representing a territory that can be picked; Only used in the distribution turn

---@class EnumTerritoryConnectionWrap # 
---| 'Normal' # A normal connection
---| 'WrapHorizontally' # A connection that wraps horizontally
---| 'WrapVertically' # A connection that wraps vertically

---@class CustomSpecialUnitBuilder: CustomSpecialUnitClass # Custom special unit builder
---@field Create fun(playerID: PlayerID): CustomSpecialUnitBuilder # Creates a new and empty CustomSpecialUnitBuilder object
---@field CreateCopy fun(clone: CustomSpecialUnit): CustomSpecialUnitBuilder # Creates a new CustomSpecialUnitBuilder object, with the same fields as the given clone
---@field Build fun(): CustomSpecialUnit # Completes the build and returns a CustomSpecialUnit that can be added to the game

---@class EnumGamePlayerState # Player state enums
---| 'Invited' # Player is invited
---| 'Playing' # Player is playing
---| 'Eliminated' # Player is eliminated
---| 'Won' # Player has won
---| 'Declined' # Player has declined the invitation
---| 'RemovedByHost' # Player was invited but removed by the host
---| 'SurrenderAccepted' # Player successfully surrendered
---| 'Booted' # Player was booted
---| 'EndedByVote' # The game ended by voting to end

---@class EnumGameState # Game state enums
---| 'WaitingForPlayers' # Game is waiting for players to join
---| 'Playing' # Game is playing
---| 'Finished' # Game has ended
---| 'DistributingTerritories' # Game is distribution territories

---@class EnumStandingFogLevel # Fog level for territory standing enums
---| 'You' # Player controls the territory
---| 'Visible' # Player can see the territory, but does not control it
---| 'OwnerOnly' # Player can see the owner of the territory only
---| 'Fogged' # Territory is fogged for the player

---@class EnumGameFogLevel # Fog level for game settings enums
---| 'ExtremeFog' # Complete fog
---| 'Foggy' # Dense fog
---| 'LightFog' # Light fog
---| 'ModerateFog'# Normal fog
---| 'NoFog' # No fog
---| 'VeryFoggy' # Heavy fog

---@class EnumStructureType # Structure type enums
---| 'City' # City
---| 'ArmyCamp' # Idle army camp
---| 'Mine' # Idle mine
---| 'Smelter' # Idle smelter
---| 'Crafter' # Idle crafter
---| 'Market' # Idle market
---| 'ArmyCache' # Idle army cache
---| 'MoneyCache' # Idle money cache
---| 'ResourceChache' # Idle resource cache
---| 'MercenaryCamp' # Idle mercenary cache
---| 'Power' # Idle power
---| 'Draft' # Idle draft
---| 'Arena' # Idle arena
---| 'Hospital' # Idle hospital
---| 'DigSite' # Idle dig site
---| 'Attack' # Idle attack
---| 'Mortar' # Idle mortar
---| 'Recipe' # Idle recipe

---@class EnumMoveOrder # Move order enums
---| 'Cycle' # Create a random move order list, and use that for every turn
---| 'NoLuckCycle' # Time spent on the first turn determines the move order
---| 'Random' # Randomise the move order every turn

---@class RoundingModeEnum # Rounding mode enums
---| 'StraightRound'
---| 'WeightedRandom'

---@class ActiveCardExpireBehaviorOptions # Active card expire behaviour enums
---| 'EndOfTurn' # Card expires at the end of the turn
---| 'BeginningOfNextTurn' # Card expires at the start of the turn

---@class EnumReinforcementCardMode # Reinforcement card mode enums
---| 'Fixed' # Armies amount is fixed
---| 'ProgressiveByNumberOfTerritories' # Progressive by the number of territories the player owns
---| 'ProgressiveByTurnNumber' # Progressive by the amount of turns that have passed

---@class EnumTurnPhase # Turn phase enums
---| 'Airlift' # Airlift turn phase
---| 'Attacks' # Attack / transfer turn phase
---| 'BlockadeCards' # Blockade card turn phase
---| 'BombCards' # Bomb card turn phase
---| 'CardsWearOff' # Cards wearing off turn phase
---| 'Deploys' # Deploy turn phase
---| 'DiplomacyCards' # Diplomacy card turn phase
---| 'Discards' # Discard cards turn phase
---| 'EmergencyBlockadeCards' # Emergency blockade card turn phase
---| 'Gift' # Gift card turn phase
---| 'OrderPriorityCards' # Priority card turn phase
---| 'Purchase' # Purchase turn phase
---| 'ReceiveCards' # Receive cards turn phase
---| 'ReinforcementCards' # Reinforcement card turn phase
---| 'SanctionCards' # Sanction card turn phase
---| 'SpyingCards' # Spy card turn phase

---@class EnumAttackTransfer # Attack / transfer enums
---| 'Attack' # Attack only
---| 'Transfer' # Transfer only
---| 'AttackTransfer' # Attack and transfer

---@class EnumResourceType # Resource type enums
---| 'Gold' # Gold enum

---@class ArmiesWL # WL Armies
---@field Create fun(armies: integer, specialUnitOpt: SpecialUnit[]): Armies # Used to create a new Armies object

---@class Boss1WL # WL Boss1
---@field CreateForScenario fun(): Boss1 # Creates a Boss1 unit for a custom scenario
---@field Create fun(playerID: PlayerID): Boss1 # Creates a Boss1 unit

---@class Boss2WL # WL Boss2
---@field CreateForScenario fun(): Boss2 # Creates a Boss2 unit for a custom scenario
---@field Create fun(playerID: PlayerID): Boss2WL # Creates a Boss2 unit

---@class Boss3WL # WL Boss3
---@field CreateForScenario fun(): Boss3WL # Creates a Boss3 unit for a custom scenario
---@field Create fun(playerID: PlayerID, stage: integer): Boss3 # Creates a Boss3 unit

---@class Boss4WL # WL Boss4
---@field CreateForScenario fun(): Boss4WL # Creates a Boss4 unit for a custom scenario
---@field Create fun(playerID: PlayerID): Boss4 # Creates a Boss4 unit

---@class CommanderWL # WL Commander
---@field CreateForScenario fun(): Commander # Creates a Commander unit for a custom scenario
---@field Create fun(playerID: PlayerID): Commander # Creates a Commander unit

---@class CardGameAbandonWL # WL CardGameAbandon
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, multiplyAmount: number): CardGameAbandon # Creates a CardGameAbandon object

---@class CardGameAirliftWL # WL CardGameAirlift
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer): CardGameAirlift # Creates a CardGameAirlift object

---@class CardGameBlockadeWL # WL CardGameBlockade
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, multiplyAmount: number): CardGameBlockade # Creates a CardGameBlockade object

---@class CardGameBombWL # WL CardGameBomb
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer): CardGameBomb # Creates a CardGameBomb object

---@class CardGameDiplomacyWL # WL CardGameDiplomacy
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, duration: integer): CardGameDiplomacy # Creates a CardGameDiplomacy object

---@class CardGameGiftWL # WL CardGameGift
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer): CardGameGift # Creates a CardGameGift object

---@class CardGameOrderDelayWL # WL CardGameOrderDelay
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer): CardGameOrderDelay # Creates a CardGameOrderDelay object

---@class CardGameOrderPriorityWL # WL CardGameOrderPriority
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer): CardGameOrderPriority # Creates a CardGameOrderPriority object

---@class CardGameReconnaissanceWL # WL CardGameReconnaissance
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, duration: integer): CardGameReconnaissance # Creates a CardGameReconnaissance object

---@class CardGameReinforcementWL # WL CardGameReinforcement
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, mode: EnumReinforcementCardMode, progressivePercentage: number, fixedArmies: integer): CardGameReinforcement # Creates a CardGameReinforcement object

---@class CardGameSanctionsWL # WL CardGameSanctions
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, duration: integer, percentage: number): CardGameSanctions # Creates a CardGameSanctions object

---@class CardGameSpyWL # WL CardGameSpy
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, duration: integer, canSpyOnNeutral: boolean): CardGameSpy # Creates a CardGameSpy object

---@class CardGameSurveillanceWL # WL CardGameSurveillance
---@field Create fun(numPieces: integer, minPerTurn: integer, weight: number, initialPieces: integer, duration: integer): CardGameSurveillance # Creates a CardGameSurveillance object

---@class NoParameterCardInstanceWL # WL NoParameterCardInstance
---@field Create fun(cardID: CardID): NoParameterCardInstance # Creates a no parameter card instance

---@class ReinforcementCardInstanceWL # WL ReinforcementCardInstance
---@field Create fun(armies: integer): ReinforcementCardInstance # Creates a reinforcement card instance

---@class CustomScenarioWL # WL CustomScenario
---@field Create fun(map: MapDetails): CustomScenario # Creates a CustomScenario object

---@class GameOrderAttackTransferWL # WL GameOrderAttackTransfer
---@field Create fun(playerID: PlayerID, from: TerritoryID, to: TerritoryID, attackOrTransfer: EnumAttackTransfer, byPercent: boolean, numArmies: Armies, attackTeammates: boolean): GameOrderAttackTransfer # Creates a GameOrderAttackTransfer object

---@class GameOrderCustomWL # WL GameOrderCustom
---@field Create fun(playerID: PlayerID, message: string, payload: string, costOpt: table<EnumResourceType, integer>, phase: EnumTurnPhase | integer | nil): GameOrderCustom # Creates a GameOrderCustom object

---@class GameOrderDeployWL # WL GameOrderDeploy
---@field Create fun(playerID: PlayerID, numArmies: integer, deployOn: TerritoryID, free: boolean): GameOrderDeploy # Creates a GameOrderDeploy object

---@class GameOrderDiscardWL # WL GameOrderDiscard
---@field Create fun(playerID: PlayerID, cardInstanceID: CardInstanceID): GameOrderDiscard # Creates a GameOrderDiscard object

---@class GameOrderEventWL # WL GameOrderEvent
---@field Create fun(playerID: PlayerID, message: string, visibleToOpt: HashSet<PlayerID>, terrModsOpt: TerritoryModification[], setResoucesOpt: table<PlayerID, table<EnumResourceType, integer>> | nil, incomeModsOpt: IncomeMod[] | nil): GameOrderEvent # Creates a GameOrderEvent object

---@class GameOrderPlayCardAbandonWL # WL GameOrderPlayCardAbandon
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetTerritoryID: TerritoryID): GameOrderPlayCardAbandon # Creates a GameOrderPlayCardAbandon object

---@class GameOrderPlayCardAirliftWL # WL GameOrderPlayCardAirlift
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, fromTerritoryID: TerritoryID, toTerritoryID: TerritoryID, numArmies: Armies): GameOrderPlayCardAirlift # Creates a GameOrderPlayCardAirlift object

---@class GameOrderPlayCardBlockadeWL # WL GameOrderPlayCardBlockade
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetTerritoryID: TerritoryID): GameOrderPlayCardBlockade # Creates a GameOrderPlayCardBlockade object

---@class GameOrderPlayCardBombWL # WL GameOrderPlayCardBomb
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetTerritoryID: TerritoryID): GameOrderPlayCardBomb # Creates a GameOrderPlayCardBomb object

---@class GameOrderPlayCardDiplomacyWL # WL GameOrderPlayCardDiplomacy
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, playerOne: PlayerID, playerTwo: PlayerID): GameOrderPlayCardDiplomacy # Creates a GameOrderPlayCardDiplomacy object

---@class GameOrderPlayCardGiftWL # WL GameOrderPlayCardGift
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, terrID: TerritoryID, giftTo: PlayerID): GameOrderPlayCardGift # Creates a GameOrderPlayCardGift object

---@class GameOrderPlayCardOrderDelayWL # WL GameOrderPlayCardOrderDelay
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID): GameOrderPlayCardOrderDelay # Creates a GameOrderPlayCardOrderDelay object

---@class GameOrderPlayCardOrderPriorityWL # WL GameOrderPlayCardOrderPriority
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID): GameOrderPlayCardOrderPriority # Creates a GameOrderPlayCardOrderPriority object

---@class GameOrderPlayCardReconnaissanceWL # WL GameOrderPlayCardReconnaissance
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetTerritoryID: TerritoryID): GameOrderPlayCardReconnaissance # Creates a GameOrderPlayCardReconnaissance object

---@class GameOrderPlayCardReinforcementWL # WL GameOrderPlayCardReinforcement
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID): GameOrderPlayCardReinforcement # Creates a GameOrderPlayCardReinforcement object

---@class GameOrderPlayCardSanctionsWL # WL GameOrderPlayCardSanctions
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, sanctionPlayer: PlayerID): GameOrderPlayCardSanctions # Creates a GameOrderPlayCardSanctions object

---@class GameOrderPlayCardSpyWL # WL GameOrderPlayCardSpy
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetPlayerID: PlayerID): GameOrderPlayCardSpy # Creates a GameOrderPlayCardSpy object

---@class GameOrderPlayCardSurveillanceWL # WL GameOrderPlayCardSurveillance
---@field Create fun(cardInstanceID: CardInstanceID, playerID: PlayerID, targetBonus: BonusID): GameOrderPlayCardSurveillance # Creates a GameOrderPlayCardSurveillance object

---@class GameOrderReceiveCardWL # WL GameOrderReceiveCard
---@field Create fun(playerID: PlayerID, instances: CardInstance[]): GameOrderReceiveCard # Creates a GameOrderReceiveCard object

---@class IncomeModWL # WL IncomeMod
---@field Create fun(pid: PlayerID, mod: integer, msg: string, bonusIDOpt: BonusID | nil): IncomeMod # Creates a IncomeMod object

---@class PlayerCardsWL # WL PlayerCards
---@field Create fun(pid: PlayerID): PlayerCards # Creates a PlayerCards object

---@class TerritoryModificationWL # WL TerritoryModification
---@field Create fun(terrID: TerritoryID): TerritoryModification # Creates a TerritoryModification object

---@class EnumModOrderControl # Enum values of ModOrderControl
---| 'Keep' # Keep the order
---| 'Skip' # Skip the order and add an order that tells the player it got skipped
---| 'SkipAndSupressSkippedMessage' # Skip the order but not add an order that tells the player it got skipped




---@class UI # Root component containing all UI related objects
---@field CreateEmpty fun(parent: UIObject): EmptyUIObject # Creates a container that displays nothing. Used to create a better layout
---@field CreateVerticalLayoutGroup fun(parent: UIObject): VerticalLayoutGroup # Creates a VerticalLayoutGroup that will display all it's children vertically
---@field CreateHorizontalLayoutGroup fun(parent: UIObject): HorizontalLayoutGroup # Create a HorizontalLayoutGroup that will display all it's children horizontally
---@field CreateLabel fun(parent: UIObject): Label # An UI object for displaying text
---@field CreateButton fun(parent: UIObject): Button # A button that the client can interact with
---@field CreateCheckBox fun(parent: UIObject): CheckBox # A UI object for inputting boolean values
---@field CreateTextInputField fun(parent: UIObject): TextInputField # A UI object for inputting text values
---@field CreateNumberInputField fun(parent: UIObject): NumberInputField # A UI object for inputting number values
---@field Destroy fun(object: UIObject) # Destroys and removes the passed UI object, note that all children are also destroyed
---@field IsDestroyed fun(object: UIObject | nil): boolean # Returns whether the passed UI object is destroyed or not
---@field Alert fun(text: string) # Creates a small alert box with the passed text
---@field PromptFromList fun(message: string, options: ListOption[]) # Allows a client to pick an option from a list
---@field InterceptNextTerritoryClick fun(callback: fun(terrDetails: TerritoryDetails)) # Intercept the next click on a territory, then invokes the passed function with the TerritoryDetails of the clicked territory. In the callback function, returning `WL.CancelClickIntercept` will allow the normal action to take place instead of blocking it
---@field InterceptNextBonusLinkClick fun(callback: fun(bonusDetails: BonusDetails)) # Intercept the next click on a bonus link, then invokes the passed function with the BonusDetails of the clicked bonus. In the callback function, returning `WL.CancelClickIntercept` will allow the normal action to take place instead of blocking it

---@class ListOption # Small table for option
---@field text string # The text displayed on the option
---@field selected fun() # Zero argument function that will be invoked if this option is picked

---@class UIObject # An UI object
---@field SetPreferredWidth fun(width: number): UIObject # Set the preferred width of the UIObject. It may not be this wide if there is not enough space, and it may be wider if FlexibleWidth is greater than 0. Defaults to -1, which is a special value meaning the object will meansure its own size based on its contents. Returns itself
---@field GetPreferredWidth fun(): number # Returns the preferred width set for this UIObject
---@field SetPreferredHeight fun(height: number): UIObject # Set the preferred height of the UIObject. It may not be this tall if there is not enough space, and it may be taller if FlexibleHeight is greater than 0. Defaults to -1, which is a special value meaning the object will meansure its own size based on its contents. Returns itself
---@field GetPreferredHeight fun(): number # Returns the preferred height set for this UIObject
---@field SetFlexibleWidth fun(width: number): UIObject # Set the flexible width of the UIObject. A number from 0 to 1 indicating how much of the remaining space this element wishes to take up. Defaults to 0, which means the element will be no wider than PreferredWidth. Set it to 1 to indicate the object should grow to encompass all remaining horizontal space it can.
---@field GetFlexibleWidth fun(): number # returns the flexible width set for this UIObject
---@field SetFlexibleHeight fun(height: number): UIObject # Set the flexible height of the UIObject. A number from 0 to 1 indicating how much of the remaining space this element wishes to take up. Defaults to 0, which means the element will be no taller than PreferredHeight. Set it to 1 to indicate the object should grow to encompass all remaining vertical space it can
---@field GetFlexibleHeight fun(): number # Returns the flexible height set for this UIObject
---@field id string # A unique UUID of this UIObject

---@class TextUIObject # An UI object that can display text
---@field SetText fun(text: string): TextUIObject # Set the text of the UI object 
---@field GetText fun(): string # Get the text of the UI object

---@class ColorUIObject # An UI object that can have a color
---@field SetColor fun(color: string): ColorUIObject # Sets the colof of the UI object. Only accepts strings of the format `#XXXXXX` where an X is a hexadecimal character
---@field GetColor fun(): string # Get the color of the UI object

---@class InteractableUIObject # An UI object that is interactable
---@field SetInteractable fun(bool: boolean): InteractableUIObject # Set the UI object interactable or not interactable
---@field GetInteractable fun(): boolean # Returns true if the client can interact with the UI object

---@class EmptyUIObject: UIObject # A container that displays nothing. Used to create a better layout

---@class VerticalLayoutGroup: UIObject # A container that stacks all its children vertically

---@class HorizontalLayoutGroup: UIObject # A container that stacks all its children horizontally

---@class Label: UIObject, TextUIObject, ColorUIObject # A UI object for displaying text

---@class Button: UIObject, TextUIObject, ColorUIObject, InteractableUIObject # A container that can be clicked
---@field SetTextColor fun(color: string): Button # Set the color of the text. Must be of the format `#XXXXXX` with every X being a hexidecimal character
---@field GetTextColor fun(): string # Get the color of the text
---@field SetOnClick fun(onClick: fun()): Button # Set the function that will be invoked when the client clicks on the button
---@field GetOnClick fun(): fun() # Get the function that will be invoked when the client clicks the button

---@class CheckBox: UIObject, TextUIObject, InteractableUIObject # A container used for getting boolean inputs from a client
---@field SetIsChecked fun(isChecked: boolean): CheckBox # Set whether the checkbox is checked or not
---@field GetIsChecked fun(): boolean # Get whether the checkbox is checked, used to retrieve boolean inputs from a player
---@field SetOnValueChanged fun(onValueChanged: fun()): CheckBox # Set the function that will be invoked when the client or mod changes the state of the checkbox
---@field GetOnValueChanged fun(): fun() # Get the function that will be invoked when the client or mod changes the state of the checkbox

---@class TextInputField: UIObject, TextUIObject, InteractableUIObject # A container used for getting string inputs
---@field SetPlaceholderText fun(text: string): TextInputField # Set the text that will be displayed when the text field is empty
---@field GetPlaceholderText fun(): string # Get the text that will be displayed when the text field is empty
---@field SetCharacterLimit fun(limit: integer): TextInputField # Set the limit of characters the client can input
---@field GetCharacterLimit fun(): integer # Get the character limit that the client can input

---@class NumberInputField: UIObject, InteractableUIObject # A container used for getting number inputs
---@field SetValue fun(value: number): NumberInputField # Set the value of the number input field
---@field GetValue fun(): number # Get the value of the number input field, used to retrieve the input of the client
---@field SetWholeNumbers fun(wholeNumbers: boolean): NumberInputField # Set whether this number input field accepts only integers or also decimal numbers
---@field GetWholeNumbers fun(): boolean # Get whether this number input field accepts only integers or also decimal numbers
---@field SetSliderMinValue fun(minValue: number): NumberInputField # Set the minimum value of the slider
---@field GetSliderMinValue fun(): number # Get the minimum value of the slider
---@field SetSliderMaxValue fun(maxValue: number): NumberInputField # Set the maximum value of the slider
---@field GetSliderMaxValue fun(): number # Get the maximum value of the slider
---@field SetBoxPreferredWidth fun(width: number): NumberInputField # Set the preferred width of just the input box
---@field GetBoxPreferredWidth fun(): number # Get the preferred width of just the input box
---@field SetSliderPreferredWidth fun(width: number): NumberInputField # Set the preferred width of just the slider
---@field GetSliderPreferredWidth fun(): number # Get the preferred width of just the slider

---@class RootParent : UIObject # The root parent of the any dialog



---@class Mod # Class for mod data
---@field Settings table # Allows for saving custom settings for your mod. Only writable in Client_PresentConfigureUI and Client_SaveCOnfigureUI hooks
---@field PublicGameData table # Public mod data that can be accessed anywhere, only writable in server hooks

---@class ModServerHook: Mod # Class for mod data for server hooks
---@field PlayerGameData table<PlayerID, table> # Player mod data object. For clients, only the table corresponding to the player will be made accessible
---@field PrivateGameData table # Private mod data, not made accessible to clients

---@class ModClientHook: Mod # Class for mod data for client hooks
---@field PlayerGameData table # The player mod data, can not be written in client hooks