Перем ПулПодключений;
Перем РазмерПула;
Перем ВремяОжиданияПодключения;
Перем МаксВремяБлокировки;

#Область ПрограммныйИнтерфейс

Процедура Инициализировать() Экспорт

	РазмерПула               = Настройки.РазмерПулаПодключений();
	ВремяОжиданияПодключения = Настройки.ВремяОжиданияСвободногоПодключения();
	МаксВремяБлокировки      = Настройки.МаксВремяБлокировкиПодключения();

	ВремПул = Новый Массив();

	Для й = 1 По РазмерПула Цикл
		ОписаниеПодключения = Новый Структура();
		ОписаниеПодключения.Вставить("Ид"              , й - 1);
		ОписаниеПодключения.Вставить("Подключение"     , Неопределено);
		ОписаниеПодключения.Вставить("Заблокировано"   , Ложь);
		ОписаниеПодключения.Вставить("НачалоБлокировки", 0);
		
		ВремПул.Добавить(ОписаниеПодключения);
	КонецЦикла;

	ПулПодключений = Новый ФиксированныйМассив(ВремПул);

КонецПроцедуры // Инициализировать()

Функция ПустойОбъектКластера(Знач ТипОбъекта, Знач Поля = "_all") Экспорт

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта);
	ПоляОбъекта.Добавить(Новый Структура("Имя, ИмяРАК, Тип, ПоУмолчанию", "Количество", "count", "Число", 0));

	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().РабочиеПроцессы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Сеансы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Соединения) Тогда
		ПоляОбъекта.Добавить(Новый Структура("Имя, ИмяРАК, Тип, ПоУмолчанию", "Длительность", "duration", "Число", 0));
	КонецЕсли;

	ПустойОбъект = Новый Соответствие();
	ПустойОбъект.Вставить("empty", Истина);

	Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

		Если Поля.Найти(ВРег(ТекПолеОбъекта.ИмяРАК)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ЗначениеПоля = Неопределено;

		Если ВРег(ТекПолеОбъекта.Тип) = "ЧИСЛО" Тогда
			ЗначениеПоля = 0;
		ИначеЕсли ВРег(ТекПолеОбъекта.Тип) = "ДАТА" Тогда
			ЗначениеПоля = Дата(1, 1, 1, 0, 0, 0);
		КонецЕсли;

		ПустойОбъект.Вставить(ТекПолеОбъекта.ИмяРАК, ЗначениеПоля);
	КонецЦикла;

	Возврат ПустойОбъект;

КонецФункции // ПустойОбъектКластера()

Функция Кластеры(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Возврат ОбъектыКластера(ТипыОбъектовКластера().Кластеры, Обновить, Поля, Фильтр);

КонецФункции // Кластеры()

Функция Кластер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Кластеры = Кластеры(Поля, Неопределено, Обновить);


	Для Каждого ТекКластер Из Кластеры Цикл
		Если ТекКластер["host"] = АдресСервера И ТекКластер["port"] = ПортСервера Тогда
			Возврат ТекКластер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Кластер()

Функция Серверы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Возврат ОбъектыКластера(ТипыОбъектовКластера().Серверы, Обновить, Поля, Фильтр);

КонецФункции // Серверы()

Функция Сервер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Серверы = Серверы(Поля, Неопределено, Обновить);

	Для Каждого ТекСервер Из Серверы Цикл
		Если ТекСервер["agent-host"] = АдресСервера И ТекСервер["agent-port"] = ПортСервера Тогда
			Возврат ТекСервер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сервер()

Функция Процессы(Знач Поля = "_all", Знач Фильтр = Неопределено,
	             Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Процессы = ОбъектыКластера(ТипыОбъектовКластера().РабочиеПроцессы, Обновить, Поля, Фильтр);

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Процессы, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Процессы;

КонецФункции // Процессы()

Функция Процесс(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Процессы = Процессы(Поля, Неопределено, Неопределено, Обновить);

	Для Каждого ТекПроцесс Из Процессы Цикл
		Если ТекПроцесс["host"] = АдресСервера И ТекПроцесс["port"] = ПортСервера Тогда
			Возврат ТекПроцесс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Процесс()

Функция ИнформационныеБазы(Знач Поля = "_summary", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Возврат ОбъектыКластера(ТипыОбъектовКластера().ИнформационныеБазы, Обновить, Поля, Фильтр);

КонецФункции // ИнформационныеБазы()

Функция ИнформационнаяБаза(ИБ, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	ИнформационныеБазы = ИнформационныеБазы(Поля, Неопределено, Обновить);

	Для Каждого ТекИБ Из ИнформационныеБазы Цикл
		Если ТекИБ["infobase-label"] = ИБ Тогда
			Возврат ТекИБ;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // ИнформационнаяБаза()

Функция Сеансы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Сеансы = ОбъектыКластера(ТипыОбъектовКластера().Сеансы, Обновить, Поля, Фильтр);

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Сеансы, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Сеансы;

КонецФункции // Сеансы()

Функция Сеанс(ИБ, Сеанс, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Сеансы = Сеансы(Поля, Неопределено, Неопределено, Обновить);

	Для Каждого ТекСеанс Из Сеансы Цикл
		Если ТекСеанс["infobase-label"] = ИБ И ТекСеанс["session-id"] = Сеанс Тогда
			Возврат ТекСеанс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сеанс()

Функция Соединения(Знач Поля = "_all", Знач Фильтр = Неопределено,
	               Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Соединения = ОбъектыКластера(ТипыОбъектовКластера().Соединения, Обновить, Поля, Фильтр);

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Соединения, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Соединения;

КонецФункции // Соединения()

Функция Соединение(ИБ, Соединение, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Соединения = Соединения(Поля, Неопределено, Неопределено, Обновить);

	Для Каждого ТекСоединение Из Соединения Цикл
		Если ТекСоединение["infobase-label"] = ИБ И ТекСоединение["conn-id"] = Соединение Тогда
			Возврат ТекСоединение;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Соединение()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

Функция ОбъектыКластера(Знач ТипОбъекта, Знач Обновить = Ложь, Знач Поля = "_all", Знач Фильтр = Неопределено)

	ОписаниеПодключения = ОписаниеПодключенияКАгенту();

	ОбъектыКластера = Неопределено;

	Попытка
		ОбъектыКластера = ОписаниеПодключения.Подключение.ОписанияОбъектовКластера(ТипОбъекта, Обновить, Поля, Фильтр);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Сообщить(СтрШаблон("При обновлении объектов ""%1"" возникла ошибка: %2%3", ТипОбъекта, Символы.ПС, ТекстОшибки),
		         СтатусСообщения.ОченьВажное);
	КонецПопытки;

	ОсвободитьПодключение(ОписаниеПодключения);

	Возврат ОбъектыКластера;

КонецФункции // ОбъектыКластера()

Функция ОписаниеПодключенияКАгенту()

	Если НЕ ТипЗнч(ПулПодключений) = Тип("ФиксированныйМассив") Тогда
		Инициализировать();
	КонецЕсли;

	ВремяНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Пока ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНачала <= ВремяОжиданияПодключения Цикл

		Для й = 0 По РазмерПула - 1 Цикл
			
			ТекОписание = ПулПодключений[й];

			Если ТекОписание.Заблокировано
			   И ТекущаяУниверсальнаяДатаВМиллисекундах() - ТекОписание.НачалоБлокировки < МаксВремяБлокировки Тогда
				Продолжить;
			КонецЕсли;

			ТекОписание.Заблокировано    = Истина;
			ТекОписание.НачалоБлокировки = ТекущаяУниверсальнаяДатаВМиллисекундах();

			Если ТекОписание.Подключение = Неопределено Тогда
				ТекОписание.Подключение = Новый ПодключениеКАгентам();
			КонецЕсли;

			Сообщить(СтрШаблон("Занимаем пул: %1", й), СтатусСообщения.ОченьВажное);

			Возврат ТекОписание;

		КонецЦикла;

	КонецЦикла;

	ВызватьИсключение "Истекло время ожидания свободного подключения";

КонецФункции // ОписаниеПодключенияКАгенту()

Процедура ОсвободитьПодключение(ОписаниеПодключения)

	ОписаниеПодключения.Заблокировано    = Ложь;
	ОписаниеПодключения.НачалоБлокировки = 0;

	Сообщить(СтрШаблон("Освободили пул: %1", ОписаниеПодключения.Ид), СтатусСообщения.ОченьВажное);

КонецПроцедуры // ОсвободитьПодключение()

Функция ТипыОбъектовКластера()

	Возврат Перечисления.РежимыАдминистрирования;

КонецФункции // ТипыОбъектовКластера()

#КонецОбласти // СлужебныеПроцедурыИФункции

Инициализировать();