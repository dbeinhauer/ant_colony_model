# Mapa
2D mrizka asi s cisly:
    -1 prekazka
    0 volno
    1 mraveniste
    2 korist
    3 past
* generovani by bylo fajn nahodne, ale dost se hodi nacitat vstupni mapy pro otestovani

# Generovani mravence
Nahodne nejakou distribuci podle mnostvi potravy v mravenisti? 
    x
Proste dany pocet mravencu v mravenisti
* vzdycky vychazeji z mraveniste

# Generovani potravy
* bud pevne rozmisteni na zacatku, nebo mozna nahodne generovat nove zdroje potravy

# Chovani mravencu
* Pohybem z mraveniste vypousteji feromony druhu 1 (aby nasli mraveniste)
* Pohybem od koristi vypousteji feromony druhu 2 (aby dalsi nasli korist)
* Feromony maji nejakou difuzi + postupem casu mizi
* mozna chci detekovat feromon na delsi vzdalenost s mensi silou (nebo proste jen sousede)


# Architektura
Vrstva 0, 0.1:
    - veci na mape
    - update fce:
        OBSTACLE -> OBSTACLE
        FREE -> FREE
        NEST -> NEST
        FOOD -> food_capacity > 0 ? FOOD : FREE
            `food_capacity` - array kapacit potravy na pozicich mapy
                - asi spis nejaky dictionary s pozicemi, kde je potrava
                - update fce:
                    ```
                    is_ant ? 
                        (food_capacity - consumption_rate > 0 ? food_capacity - consumption_rate : 0)
                        : food_capacity
                    ```
                        consumption_rate [0, 1] - jak moc se mi snizi zasoby jidla po jednom prichodu 
                        mravence

Vrstva 1, 1.1:
    2 druhy feromonu (2*2D array):
        FOOD_FEROMON - vypousti mravenec, co ma jidlo, cesta za jidlem
        NEST_FEROMON - vypousti mravenec, co jde z hnizda, cesta domu
    - difusion fce:
        `feromon_power[i, j] [0, 1]` - sila feromonu na pozici
            `x => x - fade_rate => x > 0 ? x : 0`
                - mozna nechci - ale radsi *
            `feromon_power[sousedni_pozice] = s pravdepodobnosti difusion_rate:`
                `+ feromon_power[i, j]*transfer_fade_rate`
            `fade_rate [0, 1]` - jak rychle mizi feromon (procento maximalni kapacity)
            `difusion_rate [0, 1]` - pravdepodobnost presunu feromonu na sousedni misto
            `transfer_fade_rate [0, 1]` - jak moc se zmensi sila feromonu po presunu na sousedni pozici
                - asi dava smysl neco jako 1/8 puvodni hladiny feromonu (mozna ale silnejsi, aby to uz 
                nebylo moc malo)

Vrstva 2:
    asi nejaky spojak se vsemi mravenci, co jsou na mape
    Ant
    {
        bool going_home
        pozice
        smer_pohybu - 8 moznych smeru na gridu, ale realne mozna 
            udelam neco jako 0-360 (stupne a prepocitam)
    }

    update fce:
        new_position = based on new_direction => appropriate coordinates
            new_direction: 
                ovlivnen: 
                    zmenou uhlu (cim vetsi, tim vyssi penalizace (neotoci se na miste))
                    mnozstvim feromonu na sousednich pozicich