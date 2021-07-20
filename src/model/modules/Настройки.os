
Перем ХешНастроек;                         // - Строка    - хеш макета настроек
Перем ОбновлениеНастроекПриИзменении;      // - Булево    - Истина - при изменении макета настроек,
                                           //                        настройки будут считаны заново;
Перем ВыполняетсяОбновлениеНастроек;       // - Булево    - Истина - на текущий момент выполняется
                                           //               обновление настроек в другом потоке;

Перем ПараметрыПодключения;                // - Структура - прочитанные параметры подключения к
                                           //               сервису администрирования и авторизации кластеров и ИБ

Перем РазмерПулаПодключений;               // - Число     - число одновременных подключений к сервису администрирования
Перем МаксПопытокИнициализацииКластера;    // - Число     - количество попыток инициализации кластера 1С
                                           //               обход проблемы с пусты выводом команды `rac cluster list`
Перем ИнтервалПовторнойИнициализации;      // - Число     - задержка перед повторным подключением (мсек.)
                                           //               умножается на номер попытки подключения
Перем ВремяОжиданияСвободногоПодключения;  // - Число     - время ожидания свободного подключения (мсек.),
                                           //               после которого будет сообщено об ошибке подключения
Перем МаксВремяБлокировкиПодключения;      // - Число     - максимальное время блокировки подключения (мсек.)
                                           //               после которого подключение будет принудительно освобождено

Перем ЛогироватьЗамерыВремени;             // - Булево    - Истина - будет выполняться логирование
                                           //               времени выполнения запросов в файл
Перем ФайлЛогаЗамеровВремени;              // - Строка    - путь к файлу лога замеров времени

#Область ПрограммныйИнтерфейс

// Процедура - инициализирует модуль и читает переданные настройки или настройки из файла "racsettings.json"
//
// Параметры:
//   НовыеНастройкиПодключения   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура Инициализация(Знач НовыеНастройкиПодключения = Неопределено) Экспорт

	ВыполняетсяОбновлениеНастроек = Истина;

	Если ТипЗнч(НовыеНастройкиПодключения) = Тип("Структура")
	 ИЛИ ТипЗнч(НовыеНастройкиПодключения) = Тип("Соответствие") Тогда
		НастройкиДляУстановки = НовыеНастройкиПодключения;
		ОбновлениеНастроекПриИзменении = Ложь;
	ИначеЕсли ТипЗнч(НовыеНастройкиПодключения) = Тип("Строка") Тогда
		НастройкиДляУстановки = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON(НовыеНастройкиПодключения, Истина);
		ОбновлениеНастроекПриИзменении = Ложь;
	Иначе
		НастройкиДляУстановки = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON("/config/racsettings", Истина);
		ХэшНастроек = ОбщегоНазначения.ХешМакета("/config/racsettings");
		ОбновлениеНастроекПриИзменении = Истина;
	КонецЕсли;
	
	ЗаполнитьПараметрыПодключения(НастройкиДляУстановки);
	
	ЗаполнитьПараметры(НастройкиДляУстановки);

	ВыполняетсяОбновлениеНастроек = Ложь;

КонецПроцедуры // Инициализация()

// Функция - возвращает флаг необходимости обновления настроек при изменении макета настроек
//
// Возвращаемое значение:
//   Булево               - флаг необходимости обновления настроек при изменении макета настроек
//
Функция ОбновлениеНастроекПриИзменении() Экспорт

	Возврат ОбновлениеНастроекПриИзменении;

КонецФункции // ОбновлениеНастроекПриИзменении()

// Процедура - устанавливает флаг необходимости обновления настроек при изменении макета настроек
//
// Параметры:
//   НовоеЗначение     - Булево         - новое значение флага необходимости обновления настроек
//                                        при изменении макета настроек
//
Процедура УстановитьОбновлениеНастроекПриИзменении(Знач НовоеЗначение) Экспорт

	ОбновлениеНастроекПриИзменении = НовоеЗначение;

КонецПроцедуры // ОбновлениеНастроекПриИзменении()

// Функция - возвращает текущее значение хеша макета настроек подключения к сервису администрирования
// и авторизации кластеров и ИБ
//
// Возвращаемое значение:
//   Строка               - текущее значение хеша макета настроек
//
Функция ХешНастроек() Экспорт

	Возврат ХешНастроек;

КонецФункции // ХешНастроек()

// Функция - возвращает параметры подключения к сервису администрирования
// и авторизации кластеров и ИБ
//
// Возвращаемое значение:
//   Структура               - параметры подключения
//      *Агенты    - Структура   - параметры подключения к сервисам аднистрирования 1С
//      *Кластеры  - Структура   - параметры авторизации кластеров и ИБ
//
Функция ПараметрыПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ПараметрыПодключения;

КонецФункции // ПараметрыПодключения()

// Функция - возвращает число одновременных подключений к сервису администрирования
//
// Возвращаемое значение:
//   Число     - число одновременных подключений к сервису администрирования
//
Функция РазмерПулаПодключений() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат РазмерПулаПодключений;

КонецФункции // РазмерПулаПодключений()

// Функция - возвращает количество попыток инициализации кластера 1С
// обход проблемы с пусты выводом команды `rac cluster list`
//
// Возвращаемое значение:
//   Число     - количество попыток инициализации кластера 1С
//
Функция МаксПопытокИнициализацииКластера() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат МаксПопытокИнициализацииКластера;

КонецФункции // МаксПопытокИнициализацииКластера()

// Функция - возвращает задержку перед повторным подключением к кластеру 1С (мсек.)
// умножается на номер попытки подключения
//
// Возвращаемое значение:
//   Число     - задержка перед повторным подключением (мсек.)
//
Функция ИнтервалПовторнойИнициализации() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ИнтервалПовторнойИнициализации;

КонецФункции // ИнтервалПовторнойИнициализации()

// Функция - возвращает время ожидания свободного подключения (мсек.),
// после которого будет сообщено об ошибке подключения
//
// Возвращаемое значение:
//   Число     - время ожидания свободного подключения (мсек.)
//
Функция ВремяОжиданияСвободногоПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ВремяОжиданияСвободногоПодключения;

КонецФункции // ВремяОжиданияСвободногоПодключения()

// Функция - возвращает максимальное время блокировки подключения (мсек.)
// после которого подключение будет принудительно освобождено
//
// Возвращаемое значение:
//   Число     - максимальное время блокировки подключения (мсек.)
//
Функция МаксВремяБлокировкиПодключения() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат МаксВремяБлокировкиПодключения;

КонецФункции // МаксВремяБлокировкиПодключения()

// Функция - возвращает флаг логирования замеров времени
//
// Возвращаемое значение:
//   Булево    - Истина - будет выполняться логирование
//                        времени выполнения запросов в файл
//
Функция ЛогироватьЗамерыВремени() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ЛогироватьЗамерыВремени;

КонецФункции // ЛогироватьЗамерыВрени()

// Функция - возвращает путь к файлу лога замеров времени
//
// Возвращаемое значение:
//   Строка    - путь к файлу лога замеров времени
//
Функция ФайлЛогаЗамеровВремени() Экспорт

	ПеречитатьИзмененияНастроек();

	Возврат ФайлЛогаЗамеровВремени;

КонецФункции // ФайлЛогаЗамеровВремени()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ЧтениеНастроек

// Процедура - заполняет параметры подключения к сервису администрирования 
// и авторизации кластеров из переданных настроек
//
// Параметры:
//   НастройкиДляУстановки   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура ЗаполнитьПараметрыПодключения(НастройкиДляУстановки)

	НастройкиАгентов   = ОбщегоНазначения.ПолучитьЗначениеНастройки("ras"    , НастройкиДляУстановки);
	НастройкиКластеров = ОбщегоНазначения.ПолучитьЗначениеНастройки("cluster", НастройкиДляУстановки);

	ПараметрыАгентов = Новый Соответствие();
	ИдентификаторыАгентов = Новый Массив();

	Для Каждого ТекНастройки Из НастройкиАгентов Цикл
	
		Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" И НЕ НастройкиАгентов.Количество() = 1 Тогда
			Продолжить;
		КонецЕсли;

		ПараметрыАгента = ПараметрыАгента(ТекНастройки.Ключ, НастройкиАгентов);

		ПараметрыАгентов.Вставить(ВРег(ТекНастройки.Ключ), ПараметрыАгента);

		ИдентификаторыАгентов.Добавить(ВРег(ТекНастройки.Ключ));

	КонецЦикла;

	ПараметрыКластеров = Новый Соответствие();

	Для Каждого ТекНастройки Из НастройкиКластеров Цикл
	
		ПараметрыКластера = ПараметрыКластера(ТекНастройки.Ключ, НастройкиКластеров);

		Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" Тогда
			КлючНастроек = "ПОУМОЛЧАНИЮ";
		Иначе
			КлючНастроек = ВРег(ТекНастройки.Ключ);
		КонецЕсли;

		ПараметрыКластеров.Вставить(КлючНастроек, ПараметрыКластера);

	КонецЦикла;

	ПараметрыПодключения = Новый Структура();
	ПараметрыПодключения.Вставить("Агенты"               , ПараметрыАгентов);
	ПараметрыПодключения.Вставить("ИдентификаторыАгентов", ИдентификаторыАгентов);
	ПараметрыПодключения.Вставить("Кластеры"             , ПараметрыКластеров);

КонецПроцедуры // ЗаполнитьПараметрыПодключения()

// Процедура - заполняет параметры подключения к сервису администрирования 
// и авторизации кластеров из переданных настроек
//
// Параметры:
//   НастройкиДляУстановки   - Соответствие  - настройки из которых будут заполняться параметры
//
Процедура ЗаполнитьПараметры(НастройкиДляУстановки)

	РазмерПулаПодключений              = ОбщегоНазначения.ПолучитьЗначениеНастройки("connectionPoolSize",
	                                                                                НастройкиДляУстановки);
	МаксПопытокИнициализацииКластера   = ОбщегоНазначения.ПолучитьЗначениеНастройки("reconnectAtempts",
	                                                                                НастройкиДляУстановки);
	ИнтервалПовторнойИнициализации     = ОбщегоНазначения.ПолучитьЗначениеНастройки("reconnectInterval",
	                                                                                НастройкиДляУстановки);
	ВремяОжиданияСвободногоПодключения = ОбщегоНазначения.ПолучитьЗначениеНастройки("connectionWait",
	                                                                                НастройкиДляУстановки);
	МаксВремяБлокировкиПодключения     = ОбщегоНазначения.ПолучитьЗначениеНастройки("connectionLockInterval",
	                                                                                НастройкиДляУстановки);

	ЛогироватьЗамерыВремени            = ОбщегоНазначения.ПолучитьЗначениеНастройки("logQueryDuration",
	                                                                                НастройкиДляУстановки);
	ФайлЛогаЗамеровВремени             = ОбщегоНазначения.ПолучитьЗначениеНастройки("queryDurationLogFilename",
	                                                                                НастройкиДляУстановки);

	Если РазмерПулаПодключений = Неопределено Тогда
		РазмерПулаПодключений = 10;
	КонецЕсли;
	Если МаксПопытокИнициализацииКластера = Неопределено Тогда
		МаксПопытокИнициализацииКластера = 3;
	КонецЕсли;
	Если ИнтервалПовторнойИнициализации = Неопределено Тогда
		ИнтервалПовторнойИнициализации = 1500;
	КонецЕсли;
	Если ВремяОжиданияСвободногоПодключения = Неопределено Тогда
		ВремяОжиданияСвободногоПодключения = 10000;
	КонецЕсли;
	Если МаксВремяБлокировкиПодключения = Неопределено Тогда
		МаксВремяБлокировкиПодключения = 90000;
	КонецЕсли;
	Если ЛогироватьЗамерыВремени = Неопределено Тогда
		ЛогироватьЗамерыВремени = Ложь;
	КонецЕсли;

КонецПроцедуры // ЗаполнитьПараметры()

// Функция - получает параметры агента кластера 1С
//
// Параметры:
//   Сервис                  - Строка        - идентификатор агента
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                          - параметры авторизации
//       *АдресСервиса    - Строка          - адрес подключения к сервису администрирования 1С
//       *ВерсияКлиента   - Строка          - версия утилиты RAC
//       *Администратор   - Строка          - имя администратора
//       *Пароль          - Строка          - пароль администратора
//       *ИБ              - Соответствие    - параметры авторизации ИБ
//
Функция ПараметрыАгента(Сервис, НастройкиДляУстановки)

	ПараметрыПоУмолчанию = ОбщегоНазначения.ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ОбщегоНазначения.ПолучитьЗначениеНастройки(Сервис     , НастройкиДляУстановки);

	АдресСервисаПоУмолчанию  = ОбщегоНазначения.ПолучитьЗначениеНастройки("ras"       , ПараметрыПоУмолчанию);
	ВерсияКлиентаПоУмолчанию = ОбщегоНазначения.ПолучитьЗначениеНастройки("rac"       , ПараметрыПоУмолчанию);
	
	АдресСервисаПоИмени  = ОбщегоНазначения.ПолучитьЗначениеНастройки("ras"       , ПараметрыПоИмени);
	ВерсияКлиентаПоИмени = ОбщегоНазначения.ПолучитьЗначениеНастройки("rac"       , ПараметрыПоИмени);
	Резервирует          = ОбщегоНазначения.ПолучитьЗначениеНастройки("reserves"  , ПараметрыПоИмени, "");

	Если НЕ АдресСервисаПоИмени = Неопределено Тогда
		АдресСервиса = АдресСервисаПоИмени;
	ИначеЕсли НЕ АдресСервисаПоУмолчанию = Неопределено Тогда
		АдресСервиса = АдресСервисаПоУмолчанию;
	Иначе
		АдресСервиса      = "localhost:1545"; // RAS
	КонецЕсли;
	Если НЕ ВерсияКлиентаПоИмени = Неопределено Тогда
		ВерсияКлиента = ВерсияКлиентаПоИмени;
	ИначеЕсли НЕ ВерсияКлиентаПоУмолчанию = Неопределено Тогда
		ВерсияКлиента = ВерсияКлиентаПоУмолчанию;
	Иначе
		ВерсияКлиента     = "8.3"; // RAC
	КонецЕсли;

	ПараметрыАвторизации = ПараметрыАвторизации(Сервис, НастройкиДляУстановки);

	ПараметрыСервиса = Новый Структура();
	ПараметрыСервиса.Вставить("АдресСервиса" , АдресСервиса);
	ПараметрыСервиса.Вставить("ВерсияКлиента", ВерсияКлиента);
	ПараметрыСервиса.Вставить("Резервирует"  , Резервирует);
	ПараметрыСервиса.Вставить("Администратор", ПараметрыАвторизации.Администратор);
	ПараметрыСервиса.Вставить("Пароль"       , ПараметрыАвторизации.Пароль);

	Возврат ПараметрыСервиса;

КонецФункции // ПараметрыАгента()

// Функция - получает параметры для кластера
//
// Параметры:
//   МеткаКластера           - Строка        - ключ набора параметров
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                          - параметры авторизации
//       *Администратор   - Строка          - имя администратора
//       *Пароль          - Строка          - пароль администратора
//       *ИБ              - Соответствие    - параметры авторизации ИБ
//
Функция ПараметрыКластера(МеткаКластера, НастройкиДляУстановки)
	
	ПараметрыПоИмени     = ОбщегоНазначения.ПолучитьЗначениеНастройки(МеткаКластера, НастройкиДляУстановки);
	НастройкиИБ          = ОбщегоНазначения.ПолучитьЗначениеНастройки("infobase"   , ПараметрыПоИмени);

	ПараметрыАвторизации = ПараметрыАвторизации(МеткаКластера, НастройкиДляУстановки);

	ПараметрыБаз = Новый Соответствие();

	Если ТипЗнч(НастройкиИБ) = Тип("Соответствие") Тогда
		
		Для Каждого ТекНастройки Из НастройкиИБ Цикл
		
			ПараметрыИБ = ПараметрыАвторизации(ТекНастройки.Ключ, НастройкиИБ);

			Если ВРег(ТекНастройки.Ключ) = "__DEFAULT" Тогда
				КлючНастроек = "ПОУМОЛЧАНИЮ";
			Иначе
				КлючНастроек = ВРег(ТекНастройки.Ключ);
			КонецЕсли;

			ПараметрыБаз.Вставить(КлючНастроек, ПараметрыИБ);

		КонецЦикла;

	КонецЕсли;

	ПараметрыКластера = Новый Структура();
	ПараметрыКластера.Вставить("Администратор", ПараметрыАвторизации.Администратор);
	ПараметрыКластера.Вставить("Пароль"       , ПараметрыАвторизации.Пароль);
	ПараметрыКластера.Вставить("ИБ"           , ПараметрыБаз);

	Возврат ПараметрыКластера;

КонецФункции // ПараметрыКластера()

// Функция - получает параметры авторизации из переданных настроек
//
// Параметры:
//   КлючПараметров          - Строка        - ключ набора параметров
//   НастройкиДляУстановки   - Соответствие  - настройки для чтения
//
// Возвращаемое значение:
//   Структура                       - параметры авторизации
//       *Администратор   - Строка        - имя администратора
//       *Пароль          - Строка        - пароль администратора
//
Функция ПараметрыАвторизации(КлючПараметров, НастройкиДляУстановки)
	
	ПараметрыПоУмолчанию = ОбщегоНазначения.ПолучитьЗначениеНастройки("__default", НастройкиДляУстановки);
	ПараметрыПоИмени     = ОбщегоНазначения.ПолучитьЗначениеНастройки(КлючПараметров, НастройкиДляУстановки);

	АдминистраторПоУмолчанию = ОбщегоНазначения.ПолучитьЗначениеНастройки("admin_name", ПараметрыПоУмолчанию);
	ПарольПоУмолчанию        = ОбщегоНазначения.ПолучитьЗначениеНастройки("admin_pwd" , ПараметрыПоУмолчанию);
	
	АдминистраторПоИмени = ОбщегоНазначения.ПолучитьЗначениеНастройки("admin_name", ПараметрыПоИмени);
	ПарольПоИмени        = ОбщегоНазначения.ПолучитьЗначениеНастройки("admin_pwd" , ПараметрыПоИмени);

	Если ЗначениеЗаполнено(АдминистраторПоИмени) Тогда
		Администратор = АдминистраторПоИмени;
		Если ЗначениеЗаполнено(ПарольПоИмени) Тогда
			Пароль = ПарольПоИмени;
		КонецЕсли;
	ИначеЕсли ЗначениеЗаполнено(АдминистраторПоУмолчанию) Тогда
		Администратор = АдминистраторПоУмолчанию;
		Если ЗначениеЗаполнено(ПарольПоУмолчанию) Тогда
			Пароль = ПарольПоУмолчанию;
		КонецЕсли;
	Иначе
		Администратор = "";
		Пароль        = "";
	КонецЕсли;

	ПараметрыАвторизации = Новый Структура();
	ПараметрыАвторизации.Вставить("Администратор", Администратор);
	ПараметрыАвторизации.Вставить("Пароль"       , Пароль);

	Возврат ПараметрыАвторизации;

КонецФункции // ПараметрыАвторизации()

#КонецОбласти // ЧтениеНастроек

#Область УстановкаПараметровОбъектовКластера

// Процедура - устанавливает параметры кластера из настроек
//
// Параметры:
//   Кластер         - Кластер        - объект кластера 1С
//
Процедура УстановитьПараметрыКластера(Кластер) Экспорт
	
	МеткаКластера = ВРег(СтрШаблон("%1:%2", Кластер.АдресСервера(), Кластер.ПортСервера()));

	ПараметрыКластера = ПараметрыПодключения.Кластеры[МеткаКластера];
	Если ПараметрыКластера = Неопределено Тогда
		ПараметрыКластера = ПараметрыПодключения.Кластеры["ПОУМОЛЧАНИЮ"];
	КонецЕсли;

	Кластер.УстановитьАдминистратора(ПараметрыКластера.Администратор, ПараметрыКластера.Пароль);

	СписокИБ = Кластер.ИнформационныеБазы().Список(, Истина);
	Для Каждого ТекИБ Из СписокИБ Цикл
		УстановитьПараметрыИБ(ТекИБ, ПараметрыКластера);
	КонецЦикла;

КонецПроцедуры // УстановитьПараметрыКластера()

// Процедура - устанавливает параметры информационной базы из настроек
//
// Параметры:
//   ИБ                  - ИнформационнаяБаза  - объект информационной базы 1С
//   ПараметрыКластера   - Соответствие        - параметры кластера
//
Процедура УстановитьПараметрыИБ(ИБ, ПараметрыКластера)
	
	Если НЕ (ПараметрыКластера.Свойство("ИБ") И ТипЗнч(ПараметрыКластера.ИБ) = Тип("Соответствие")) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыИБ = ПараметрыКластера.ИБ[ВРег(ИБ.Имя())];
	Если ПараметрыИБ = Неопределено Тогда
		ПараметрыИБ = ПараметрыКластера.ИБ["ПОУМОЛЧАНИЮ"];
	КонецЕсли;

	Администратор = "";
	Пароль = "";
	Если ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ.Свойство("Администратор", Администратор);
		ПараметрыИБ.Свойство("Пароль", Пароль);
	КонецЕсли;

	ИБ.УстановитьАдминистратора(Администратор, Пароль);

КонецПроцедуры // УстановитьПараметрыИБ()

#КонецОбласти // УстановкаПараметровКластера

#Область СлужебныеПроцедурыИФункции

Процедура ПеречитатьИзмененияНастроек()

	Если ВыполняетсяОбновлениеНастроек Тогда
		Возврат;
	КонецЕсли;
	
	НовыйХэшНастроек = ОбщегоНазначения.ХешМакета("/config/racsettings");

	Если НЕ ОбновлениеНастроекПриИзменении ИЛИ ХешНастроек = НовыйХэшНастроек Тогда
		Возврат;
	КонецЕсли;

	Инициализация();

КонецПроцедуры // ПеречитатьИзмененияНастроек()

#КонецОбласти // СлужебныеПроцедурыИФункции

Инициализация();