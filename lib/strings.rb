STRINGS = {}

STRINGS[:hello] = <<~HELLO
  Здравствуйте!

  Этот бот позволяет следить за результатами игроков, публикуемыми на сайте chess-results.com.

  Введите номер турнира, который Вас интересует.
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

STRINGS[:player_added] = 'Игрок добавлен в список отслеживания'

STRINGS[:row] = '//table[@class="CRs1"]/tr/td[%{white_snr}][normalize-space(text())=%{snr}]/../td | 
  //table[@class="CRs1"]/tr/td[%{black_snr}][normalize-space(text())=%{snr}]/../td'
