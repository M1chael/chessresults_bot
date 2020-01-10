STRINGS = {}

STRINGS[:hello] = <<~HELLO
  Здравствуйте!

  Этот бот позволяет следить за результатами игроков, публикуемыми на сайте chess-results.com.

  Для добавления игрока в список отслеживания введите номер турнира, который Вас интересует. 
  Для удаления игорка из списка отслеживания введите команду /list.
HELLO

STRINGS[:choose_player] = <<~CP 
  Название турнира: <b>%{title}</b>
  Дата и время начала: %{start_date} %{start_time}
  Дата окончания: %{finish_date}

  🔽 Выберите участника 🔽
CP

STRINGS[:draw] = <<~DRAW
  <b>%{tournament}</b>

  %{rd} тур состоится %{date} в %{time}
  %{player} играет %{color} за %{desk} доской
  Соперник — %{opponent} (рейтинг: %{rating})
DRAW

STRINGS[:result] = <<~RES
  <b>%{tournament}</b>

  По итогам %{rd} тура %{player} с результатом %{score} занимает %{rank} место в турнирной таблице
RES

STRINGS[:nothing_found] = <<~NF
  🤷‍♂️ Ничего не найдено. Попробуйте ещё раз.

  Примечание: бот может отслеживать только активные турниры с известной датой окончания.
NF

STRINGS[:tracker_added] = 'Игрок добавлен в список отслеживания'

STRINGS[:tracker_deleted] = 'Игрок удалён из списка отслеживания'

STRINGS[:row] = '//table[@class="CRs1"]/tr/td[%{white_snr}][normalize-space(text())=%{snr}]/../td | 
  //table[@class="CRs1"]/tr/td[%{black_snr}][normalize-space(text())=%{snr}]/../td'

STRINGS[:tracker] = <<~TR
  Турнир: %{tournament}
  Участник: %{name} 
TR

STRINGS[:notrackers] = 'В вашем списке отслеживания нет ни одного игрока'
