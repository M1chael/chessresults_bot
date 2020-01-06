STRINGS = {}

STRINGS[:hello] = <<~HELLO
  Здравствуйте!

  Этот бот позволяет следить за результатами игроков, публикуемыми на сайте chess-results.com.

  Введите номер турнира, который Вас интересует.
HELLO

STRINGS[:choose_player] = <<~CP 
  Название турнира: <b>%{title}</b>
  Дата начала: %{start_date}
  Дата окончания: %{finish_date}

  🔽 Выберите участника 🔽
CP

STRINGS[:nothing_found] = '🤷‍♂️ Ничего не найдено. Попробуйте ещё раз.'

# STRINGS[:search_player] = 'Введите <b>имя и фамилию</b> игрока через пробел. Порядок важен, регистр — нет.'

# STRINGS[:error] = '❌ Ошибка: не удалось обработать введённые данные. Попробуйте ещё раз.'

# STRINGS[:nobody] = <<~NB
#   👤 Имя: <b>%{name}</b>
#          Фамилия: <b>%{surname}</b>

#   🤷‍♂️ Игрок не найден

#   Примечание: бот может найти и отслеживать только игроков с присвоенными ID.
# NB

# STRINGS[:player] = <<~PLAYER
#   👤 [%{fed}] <b>%{fullname}</b>
#          ID: %{number}
#          Клуб/город: %{club}

#   Турниры:%{tournaments}
# PLAYER
    
# STRINGS[:not_finished_tournament] = "\n🚩 <b>%{title}</b>\n%{start_date} — %{finish_date}\n"
# STRINGS[:finished_tournament] = "\n🏁 %{title}\n%{start_date} — %{finish_date}\n"

# STRINGS[:callback_response] = {}
# STRINGS[:callback_response][:add] = 'Игрок добавлен в список отслеживания'
# STRINGS[:callback_response][:del] = 'Игрок удалён из списка отслеживания'
STRINGS[:player_added] = 'Игрок добавлен в список отслеживания'

STRINGS[:row] = '//table[@class="CRs1"]/tr/td[%{white_snr}][normalize-space(text())=%{snr}]/../td | 
  //table[@class="CRs1"]/tr/td[%{black_snr}][normalize-space(text())=%{snr}]/../td'
