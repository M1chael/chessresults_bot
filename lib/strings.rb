STRINGS = {}

STRINGS[:hello] = <<~HELLO
  Здравствуйте!

  Этот бот позволяет следить за результатами игроков, публикуемыми на сайте chess-results.com.

  <b>Список команд</b>:
  /start — вывод данного сообщения
  /find — поиск игрока по имени и фамилии для добавления в список отслеживания
  /list — вывод списка отслеживаемых игроков с возможностью удаления
HELLO

STRINGS[:search_player] = 'Введите <b>имя и фамилию</b> игрока через пробел. Порядок важен, регистр — нет.'

STRINGS[:error] = '❌ Ошибка: не удалось обработать введённые данные. Попробуйте ещё раз.'

STRINGS[:nobody] = <<~NB
  👤 Имя: <b>%{name}</b>
         Фамилия: <b>%{surname}</b>

  🤷‍♂️ Игрок не найден

  Примечание: бот может найти и отслеживать только игроков с присвоенными ID.
NB

STRINGS[:player] = <<~PLAYER
  👤 [%{fed}] <b>%{fullname}</b>
         ID: %{number}
         Клуб/город: %{club}

  Турниры:%{tournaments}
PLAYER
    
STRINGS[:not_finished_tournament] = "\n🚩 <b>%{name} — %{finish_date}</b>"
STRINGS[:finished_tournament] = "\n🏁 %{name} — %{finish_date}"

STRINGS[:callback_response] = {}
STRINGS[:callback_response][:add] = 'Игрок добавлен в список отслеживания'
STRINGS[:callback_response][:del] = 'Игрок удалён из списка отслеживания'
