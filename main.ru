from telethon import TelegramClient, events, functions
from telethon.sessions import StringSession
import asyncio

# === ТВОИ ДАННЫЕ ===
API_ID = 39015495
API_HASH = "70712bbbb81c133662765f78b3aed6d4"
BOT_TOKEN = "8542673729:AAFeI14J852Pt3qW7dmMFV0mY0iK0eKFl34"  # Твой токен!

# Куда присылать уведомления
NOTIFY_CHAT = "@Michailat"

# Твоя сессия (уже вставлена)
SESSION_STRING = "1ApWapzMBu62-XlzJmqhID4IYJmv6KIubJWPGU6DbB6MUIOQLlnVOmnQnbokZ4Dc5e55VBrdPvEmLw0XSvGNqk1mopkL0Bqqn1KFubyw2tGbZqjE5Y8ZI6nYAALmn2u7MKTwi04NKksESZ1gzGpjM9JbYQ6R5gYD44c-kgAIyIyTcAPuAXEad39FTmqgIabN0DctGwXNzTm_MG6o6qmbT-IQZnU9RXVnwiFgl53OfRb4pmokxGeNdubsghFPzEMTpw0z897ac4ydXxICHtvA59jGYMUZ9fAmw1G2nsvqxM137dD-f1FWY6zSUBFDw2gPbmkwXKKdNlDXz9ckBQ1qhTKcn2rVWt28"

# === ВСЕ ПОДАРКИ ИЗ ТВОЕГО СПИСКА С ДИАПАЗОНАМИ ===
GIFTS_TO_MONITOR = {
    5981026247860290310: ("Sleigh Bell", 0, 1000),
    6012435906336654262: ("Snoop Cigar", 0, 1300),
    6014675319464657779: ("Low Rider", 0, 5000),
    6014697240977737490: ("Westside Sign", 0, 9200),
    6005797617768858105: ("Artisan Brick", 0, 9000),
    6005880141270483700: ("Jolly Chimp", 0, 850),
    5933793770951673155: ("Neko Helmet", 0, 4600),
    5933937398953018107: ("Ionic Dryer", 0, 2000),
    5897593557492957738: ("Top Hat", 0, 1250),
    5870661333703197240: ("Bonded Ring", 0, 6800),
    5870862540036113469: ("Joyful Bundle", 0, 899),
    5870720080265871962: ("Nail Bracelet", 0, 15500),
    5868595669182186720: ("Valentine Box", 0, 1350),
    5868348541058942091: ("Love Potion", 0, 2050),
    5868220813026526561: ("Toy Bear", 0, 4700),
    5868503709637411929: ("Diamond Ring", 0, 3700),
    5868561433997870501: ("Cupid Charm", 0, 2600),
    5868659926187901653: ("Loot Bag", 0, 15000),
    5870947077877400011: ("Sky Stilettos", 0, 1400),
    5868455043362980631: ("Heart Locket", 0, 300000),
    5935936766358847989: ("Bunny Muffin", 0, 860),
    5895518353849582541: ("Mighty Arm", 0, 28000),
    5895328365971244193: ("Heroic Helmet", 0, 33000),
    5936043693864651359: ("Swiss Watch", 0, 6500),
    5936085638515261992: ("Signet Ring", 0, 4400),
    5933531623327795414: ("Genie Lamp", 0, 6400),
    5933629604416717361: ("Astral Shard", 0, 23000),
    5933671725160989227: ("Precious Peach", 0, 50000),
    5936013938331222567: ("Plush Pepe", 0, 1000000),
    5915550639663874519: ("Love Candle", 0, 1300),
    5915502858152706668: ("Jelly Bunny", 0, 890),
    5915733223018594841: ("Hanging Star", 0, 960),
    5915521180483191380: ("Durov’s Cap", 0, 120000),
    5913517067138499193: ("Perfume Bottle", 0, 11000),
    5879737836550226478: ("Mini Oscar", 0, 12000),
    5882125812596999035: ("Eternal Rose", 0, 3100),
    5882252952218894938: ("Berry Box", 0, 870),
    5859442703032386168: ("Gem Signet", 0, 8500),
    5857140566201991735: ("Vintage Cigar", 0, 4350),
    5856973938650776169: ("Record Player", 0, 1670),
    5846226946928673709: ("Magic Potion", 0, 10500),
    5846192273657692751: ("Electric Skull", 0, 4300),
    5845776576658015084: ("Kissed Frog", 0, 5600),
    5825480571261813595: ("Evil Eye", 0, 870),
    5843762284240831056: ("Ion Gem", 0, 12000),
    5841689550203650524: ("Sharp Tongue", 0, 5900),
    5841632504448025405: ("Mad Pumpkin", 0, 1700),
    5841391256135008713: ("Trapped Heart", 0, 1600),
    5839038009193792264: ("Skull Flower", 0, 1450),
    5841336413697606412: ("Crystal Ball", 0, 1400),
    5837063436634161765: ("Flying Broom", 0, 1400),
    5836780359634649414: ("Voodoo Doll", 0, 3700),
    5837059369300132790: ("Scared Cat", 0, 11000),
    5167939598143193218: ("Sakura Flower", 0, 960),
    # Твои старые (если хочешь оставить)
    5983471780763796287: ("Santa Hat", 80, 2000),
    5783075783622787539: ("Homemade Cake", 200, 5000),
    6003735372041814769: ("Holiday Drink", 50, 1500),
    6012607142387778152: ("Swag Bag", 300, 800),
    5839094187366024301: ("Khabib’s Papakha", 2000, 40000),
}

seen_listings = set()

# Userbot-клиент
user_client = TelegramClient(StringSession(SESSION_STRING), API_ID, API_HASH)

# Бот-клиент
bot_client = TelegramClient("gift_bot", API_ID, API_HASH).start(bot_token=BOT_TOKEN)

async def check_gifts():
    new_notifications = []
    for gift_id, (name, min_p, max_p) in GIFTS_TO_MONITOR.items():
        offset = ""
        while True:
            try:
                result = await user_client(functions.payments.GetResaleStarGiftsRequest(
                    gift_id=gift_id,
                    sort_by_price=True,
                    offset=offset,
                    limit=50
                ))

                for gift in result.gifts:
                    price = gift.price
                    if min_p <= price <= max_p:
                        listing_id = gift.msg_id or gift.id
                        if listing_id not in seen_listings:
                            seen_listings.add(listing_id)
                            slug = getattr(gift, "slug", f"gift_{gift_id}")
                            link = f"https://t.me/gift?slug={slug}"
                            message = (
                                f"🎁 <b>{name}</b>\n"
                                f"💰 Цена: {price} ⭐\n"
                                f"📊 Твой диапазон: {min_p}–{max_p} ⭐\n"
                                f"🔗 <a href='{link}'>Открыть листинг</a>"
                            )
                            new_notifications.append(message)

                if not result.next_offset:
                    break
                offset = result.next_offset
            except Exception as e:
                if "STARGIFT_INVALID" in str(e):
                    break
                else:
                    print(f"Ошибка проверки {name}: {e}")
                    break
    return new_notifications

async def monitoring_task():
    await user_client.start()
    print("Мониторинг подарков запущен в фоне...")
    while True:
        try:
            notifications = await check_gifts()
            if notifications:
                for msg in notifications:
                    await bot_client.send_message(NOTIFY_CHAT, msg, parse_mode="html")
            await asyncio.sleep(60)
        except Exception as e:
            print(f"Ошибка в мониторинге: {e}")
            await asyncio.sleep(60)

@bot_client.on(events.NewMessage(pattern="/start"))
async def start(event):
    await event.reply(
        "🚀 <b>Gift Sniper Bot активирован!</b>\n\n"
        "Я круглосуточно мониторю resale-маркет Telegram Gifts.\n"
        f"Отслеживаю <b>{len(GIFTS_TO_MONITOR)}</b> подарков с индивидуальными ценами.\n\n"
        "Как только появится выгодный листинг — пришлю тебе ссылку мгновенно!\n\n"
        "Команда /status — проверить статус.",
        parse_mode="html",
    )

@bot_client.on(events.NewMessage(pattern="/status"))
async def status(event):
    await event.reply(
        f"🟢 <b>Бот работает</b>\n"
        f"📊 Отслеживаю: {len(GIFTS_TO_MONITOR)} подарков\n"
        f"🔄 Проверка: каждые 60 секунд\n"
        f"📩 Уведомления: сюда",
        parse_mode="html",
    )

async def main():
    print("Запуск Gift Sniper Bot...")
    asyncio.create_task(monitoring_task())
    await bot_client.run_until_disconnected()

with bot_client:
    bot_client.loop.run_until_complete(main())
