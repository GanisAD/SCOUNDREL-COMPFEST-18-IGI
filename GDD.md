# WEEK 2  - Game Design Document

## **Game Overview**

1. **High Concept** : game tentang petualang yang menjelajahi labirin misterius dengan memanfaatkan apapun yang ada di dalam labirin itu.
2. **Genre** : Rougelike, Adventure, Turn Based, Card Game, Resource Management.
3. **Target Player** : Rougelike Player, Casual Player, People who enjoy managing resources.
4. **Player Experience** : Banyak merasakan trade-off dan pemilihan prioritas.
5. **Design Pillars** : Replayable, Fast-Paced Challenge, Fun, Adaptation, Trade-Offs.

## **Core Gameplay**

1. **Player Goal** : Player harus menelusuri keseluruhan 13 lantai + 1 atap dari labirin.
2. **Core Loop** : pilih 4 ruangan -> memutuskan mundur atau tidak -> lanjut ke lantai berikutnya
3. **Core Mechanic** : Scroundel exploration dengan slay the spire combat
4. **Game Rule** : Player tidak boleh mati sampai ke atap labirin

## **Player**

1. **Player action** : Tap, Drag, Hold
2. **Player Abilities** : Bisa berinteraksi dengan kartu
3. **Player State** : Combat = ketika bertemu musuh, Explore = ketika mengitari lantai atau ruangan
4. **Player Resource** : Health Point, Mana Point, Weapon Durability

## **Gameplay Element**

1. **Enemies** : Normal Enemy, Elite Enemy, Boss.
2. **Obstacles Hazards** : Ada ruangan yang memberikan debuff kepada player
3. **Interactable** : Player bisa berinteraksi dengan ruangan, elevator, dan juga altar.
4. **Item Resource** : Weapon & Potion

## **Content Challenge**

1. **Resource Constraint** : Player secara konstan memiliki resources yang sedikit dan pilihan yang       sempit
2. **Weighted RNG** : Setiap kali player naik lantai, RNG dibuat semakin menyulitkan player.
3. **Balancing** : Player tetap akan diberikan beberapa kemudahan seperti buff dan juga senjata.

## **Game Flow**

1. **Game State** : Main menu, Setting,  Gameplay, Score Result
2. **Game Flow** : Main Menu -> Gameplay -> Result -> Retry
3. **Win Lose Condition** : Win = Jika player berhasil mengalahkan boss, Lose = jika player mati

## **UI HUD**

1. **Information Requirement** : 
	1. **Exploration**: Remaining HP, Weapon Durability,  Debuff, Buff.
	2. **Combat :** Current HP, Current Mana , Block Point, Buff Effect, Debuff Effect, Whose Turn.
2. **HUD** : 
	1. **Exploration :** HP Bar, Weapon Slot, Effect Slot
	2. **Combat :** HP Bar**,** Mana Bar, Block Stats, Buff Stats & Icon, Debuff Stats & Icon. ****
