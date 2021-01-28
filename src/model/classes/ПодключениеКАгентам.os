﻿#Использовать irac

Перем ПараметрыПодключения;
Перем Агенты;
Перем Кластеры;
Перем Серверы;
Перем Процессы;
Перем ИнформационныеБазы;
Перем Сеансы;
Перем Соединения;

#Область ОбработчикиСобытийОбъекта

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура ПриСозданииОбъекта(Знач НастройкиПодключения = Неопределено)

	ИнициализироватьАгентыУправленияКластерами(НастройкиПодключения);

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // ОбработчикиСобытийОбъекта

#Область ПрограммныйИнтерфейс

// Функция - возвращает структуру с подключениями к агентам управления кластерами
//
// Возвращаемое значение:
//   Структура     - структура с подключениями к агентам управления кластерами
//
Функция Агенты() Экспорт
	
	Возврат Агенты;

КонецФункции // Агенты()

// Функция - возвращает структуру параметров подключения к агентам управления кластерами
//
// Возвращаемое значение:
//   Структура     - структура параметров подключения к агентам управления кластерами
//
Функция ПараметрыПодключения() Экспорт
	
	Возврат ПараметрыПодключения;

КонецФункции // ПараметрыПодключения()

// Процедура инициализирует подключения к агентам управления кластерами
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура ИнициализироватьАгентыУправленияКластерами(Знач НастройкиПодключения = Неопределено) Экспорт
	
	Если ТипЗнч(НастройкиПодключения) = Тип("Структура") Тогда
		ПараметрыПодключения = НастройкиПодключения;
	ИначеЕсли ТипЗнч(НастройкиПодключения) = Тип("Строка") Тогда
		ПараметрыПодключения = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON(НастройкиПодключения, Истина);
	Иначе
		ПараметрыПодключения = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON("/config/racsettings", Истина);
	КонецЕсли;

	Агенты = Новый Соответствие();

	Для Каждого ТекПараметры Из ПараметрыПодключения Цикл
	
		Если ТекПараметры.Ключ = "__default" И НЕ ПараметрыПодключения.Количество() = 1 Тогда
			Продолжить;
		КонецЕсли;

		УправлениеКластером = ИнициализироватьАгента(ПараметрыПодключения, ТекПараметры.Ключ);

		Агенты.Вставить(ВРег(ТекПараметры.Ключ),
		                Новый Структура("Резервирует, Агент",
		                                ВРег(ТекПараметры.Значение["reserves"]),
		                                УправлениеКластером));
	
	КонецЦикла;

КонецПроцедуры // ИнициализироватьАгентыУправленияКластерами()

Функция ПолучитьОбъектыКластера(Знач ТипОбъекта, Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ДобавленныеОбъекты = Новый Соответствие();

	ОбъектыКластера = Новый Массив();

	Для Каждого ТекАгент Из Агенты Цикл

		ОписаниеАгента = ТекАгент.Значение;

		Если ЗначениеЗаполнено(ОписаниеАгента.Резервирует) Тогда
			Если ТипЗнч(Агенты[ОписаниеАгента.Резервирует]) = Тип("Структура")
			   И Агенты[ОписаниеАгента.Резервирует].Свойство("Агент") Тогда
				КластерыАгента = КластерыАгента(Агенты[ОписаниеАгента.Резервирует].Агент, Поля);
				Если КластерыАгента.Количество() > 0 Тогда
					Продолжить;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;

		ОбъектыАгента = Новый Массив();

		Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Кластеры) Тогда
			ОбъектыАгента = КластерыАгента(ОписаниеАгента.Агент, Поля);
		ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Серверы) Тогда
			ОбъектыАгента = СерверыАгента(ОписаниеАгента.Агент, Поля);
		ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().РабочиеПроцессы) Тогда
			ОбъектыАгента = ПроцессыАгента(ОписаниеАгента.Агент, Поля);
		ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().ИнформационныеБазы) Тогда
			ОбъектыАгента = ИБАгента(ОписаниеАгента.Агент, Поля);
		ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Сеансы) Тогда
			ОбъектыАгента = СеансыАгента(ОписаниеАгента.Агент, Поля);
		ИначеЕсли ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Соединения) Тогда
			ОбъектыАгента = СоединенияАгента(ОписаниеАгента.Агент, Поля);
		КонецЕсли;

		Для Каждого ТекОбъект Из ОбъектыАгента Цикл
			Если ДобавленныеОбъекты[ТекОбъект[ТипОбъекта]] = Неопределено Тогда
				ДобавленныеОбъекты.Вставить(ТекОбъект[ТипОбъекта], Истина);
			Иначе
				Продолжить;
			КонецЕсли;

			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекОбъект, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			ОбъектыКластера.Добавить(ТекОбъект);
		КонецЦикла;

	КонецЦикла;

	Возврат ОбъектыКластера;

КонецФункции // ПолучитьОбъектыКластера()

Функция ПустойОбъектКластера(Знач ТипОбъекта, Знач Поля = "_all") Экспорт

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипОбъекта);
	ПоляОбъекта.Добавить(Новый Структура("Имя, ИмяРАК, Тип", "Количество", "count", "Число"));

	Если ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().РабочиеПроцессы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Сеансы)
	 ИЛИ ВРег(ТипОбъекта) = ВРег(ТипыОбъектовКластера().Соединения) Тогда
		ПоляОбъекта.Добавить(Новый Структура("Имя, ИмяРАК, Тип", "Длительность", "duration", "Число"));
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

	Если Обновить ИЛИ Кластеры = Неопределено Тогда
		Кластеры = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Кластеры, Поля, Фильтр);
	КонецЕсли;

	Возврат Кластеры;

КонецФункции // Кластеры()

Функция Кластер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Кластеры = Неопределено Тогда
		Кластеры = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Кластеры, Поля);
	КонецЕсли;

	Для Каждого ТекКластер Из Кластеры Цикл
		Если ТекКластер["host"] = АдресСервера И ТекКластер["port"] = ПортСервера Тогда
			Возврат ТекКластер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Кластер()

Функция Серверы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Серверы = Неопределено Тогда
		Серверы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Серверы, Поля, Фильтр);
	КонецЕсли;

	Возврат Серверы;

КонецФункции // Серверы()

Функция Сервер(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Серверы = Неопределено Тогда
		Серверы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Серверы, Поля);
	КонецЕсли;

	Для Каждого ТекСервер Из Серверы Цикл
		Если ТекСервер["agent-host"] = АдресСервера И ТекСервер["agent-port"] = ПортСервера Тогда
			Возврат ТекСервер;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сервер()

Функция Процессы(Знач Поля = "_all", Знач Фильтр = Неопределено,
	             Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Процессы = Неопределено Тогда
		Процессы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().РабочиеПроцессы, Поля, Фильтр);
	КонецЕсли;

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Процессы, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Процессы;

КонецФункции // Процессы()

Функция Процесс(АдресСервера, ПортСервера, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Процессы = Неопределено Тогда
		Процессы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().РабочиеПроцессы, Поля);
	КонецЕсли;

	Для Каждого ТекПроцесс Из Процессы Цикл
		Если ТекПроцесс["host"] = АдресСервера И ТекПроцесс["port"] = ПортСервера Тогда
			Возврат ТекПроцесс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Процесс()

Функция ИнформационныеБазы(Знач Поля = "_summary", Знач Фильтр = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ ИнформационныеБазы = Неопределено Тогда
		ИнформационныеБазы =  ПолучитьОбъектыКластера(ТипыОбъектовКластера().ИнформационныеБазы, Поля, Фильтр);
	КонецЕсли;

	Возврат ИнформационныеБазы;

КонецФункции // ИнформационныеБазы()

Функция ИнформационнаяБаза(ИБ, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ ИнформационныеБазы = Неопределено Тогда
		ИнформационныеБазы =  ПолучитьОбъектыКластера(ТипыОбъектовКластера().ИнформационныеБазы, Поля);
	КонецЕсли;

	Для Каждого ТекИБ Из ИнформационныеБазы Цикл
		Если ТекИБ["infobase-label"] = ИБ Тогда
			Возврат ТекИБ;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // ИнформационнаяБаза()

Функция Сеансы(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Сеансы = Неопределено Тогда
		Сеансы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Сеансы, Поля, Фильтр);
	КонецЕсли;

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Сеансы, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Сеансы;

КонецФункции // Сеансы()

Функция Сеанс(ИБ, Сеанс, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Сеансы = Неопределено Тогда
		Сеансы = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Сеансы, Поля);
	КонецЕсли;

	Для Каждого ТекСеанс Из Сеансы Цикл
		Если ТекСеанс["infobase-label"] = ИБ И ТекСеанс["session-id"] = Сеанс Тогда
			Возврат ТекСеанс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сеанс()

Функция Соединения(Знач Поля = "_all", Знач Фильтр = Неопределено,
	               Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Соединения = Неопределено Тогда
		Соединения = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Соединения, Поля, Фильтр);
	КонецЕсли;

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Соединения, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Соединения;

КонецФункции // Соединения()

Функция Соединение(ИБ, Соединение, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить ИЛИ Соединения = Неопределено Тогда
		Соединения = ПолучитьОбъектыКластера(ТипыОбъектовКластера().Соединения, Поля);
	КонецЕсли;

	Для Каждого ТекСоединение Из Соединения Цикл
		Если ТекСоединение["infobase-label"] = ИБ И ТекСоединение["conn-id"] = Соединение Тогда
			Возврат ТекСоединение;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Соединение()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхКластера

Функция КластерыАгента(Знач Агент, Знач Поля)

	КластерыАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().Кластеры);

	Для Каждого ТекКластер Из СписокКластеров Цикл

		ОписаниеКластера = Новый Соответствие();
		Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
			ОписаниеКластера.Вставить("agent", СтрШаблон("%1:%2",
			                                             Агент.АдресСервераАдминистрирования(),
			                                             Агент.ПортСервераАдминистрирования()));
		КонецЕсли;
		Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
			ОписаниеКластера.Вставить("count", 1);
		КонецЕсли;

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл
			
			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если Поля.Найти(ВРег(ИмяПоля)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекКластер[ТекПолеОбъекта.Имя];
			Если ИмяПоля = "cluster" Тогда
				ОписаниеКластера.Вставить("cluster-label", СтрШаблон("%1:%2",
				                                                     ТекКластер.Получить("АдресСервера"),
				                                                     ТекКластер.Получить("ПортСервера")));
			ИначеЕсли ИмяПоля = "name" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеКластера.Вставить(ИмяПоля, ЗначениеЭлемента);
		КонецЦикла;

		КластерыАгента.Добавить(ОписаниеКластера);

	КонецЦикла;

	Возврат КластерыАгента;

КонецФункции // КластерыАгента()

#КонецОбласти // ПолучениеДанныхКластера

#Область ПолучениеДанныхСерверов

Функция СерверыАгента(Знач Агент, Знач Поля)

	СерверыАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл

		СерверыКластера = СерверыКластера(ТекКластер, Поля);

		Для Каждого ТекСервер Из СерверыКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСервер.Вставить("agent", СтрШаблон("%1:%2",
				                                      Агент.АдресСервераАдминистрирования(),
				                                      Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСервер.Вставить("cluster"      , ТекКластер.Ид());
				ТекСервер.Вставить("cluster-host" , ТекКластер.АдресСервера());
				ТекСервер.Вставить("cluster-port" , ТекКластер.ПортСервера());
				ТекСервер.Вставить("cluster-label",
				                   СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСервер.Вставить("count", 1);
			КонецЕсли;
	
			СерверыАгента.Добавить(ТекСервер);

		КонецЦикла;

	КонецЦикла;

	Возврат СерверыАгента;

КонецФункции // СерверыАгента()

Функция СерверыКластера(Знач Кластер, Знач Поля)

	СерверыКластера = Новый Массив();
	
	СписокСерверов = Кластер.Серверы().Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().Серверы);

	Для Каждого ТекСервер Из СписокСерверов Цикл

		ОписаниеСервера = Новый Соответствие();

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если Поля.Найти(ВРег(ИмяПоля)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСервер[ТекПолеОбъекта.Имя];
			Если ИмяПоля = "server" Тогда
				ОписаниеСервера.Вставить("server-host" , ТекСервер.Получить("АдресАгента"));
				ОписаниеСервера.Вставить("server-label", СтрШаблон("%1:%2",
				                                                   ТекСервер.Получить("АдресАгента"),
				                                                   ТекСервер.Получить("ПортАгента")));
			ИначеЕсли ИмяПоля = "name" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеСервера.Вставить(ИмяПоля, ЗначениеЭлемента);
		КонецЦикла;

		СерверыКластера.Добавить(ОписаниеСервера);

	КонецЦикла;

	Возврат СерверыКластера;
	
КонецФункции // СерверыКластера()

#КонецОбласти // ПолучениеДанныхСерверов

#Область ПолучениеДанныхПроцессов

Функция ПроцессыАгента(Знач Агент, Знач Поля)

	ПроцессыАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл
	
		ПроцессыКластера = ПроцессыКластера(ТекКластер, Поля);

		Для Каждого ТекПроцесс Из ПроцессыКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекПроцесс.Вставить("agent", СтрШаблон("%1:%2",
				                                     Агент.АдресСервераАдминистрирования(),
				                                     Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекПроцесс.Вставить("cluster"      , ТекКластер.Ид());
				ТекПроцесс.Вставить("cluster-host" , ТекКластер.АдресСервера());
				ТекПроцесс.Вставить("cluster-port" , ТекКластер.ПортСервера());
				ТекПроцесс.Вставить("cluster-label",
				                    СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекПроцесс.Вставить("count", 1);
			КонецЕсли;

			ПроцессыАгента.Добавить(ТекПроцесс);

		КонецЦикла;

	КонецЦикла;

	Возврат ПроцессыАгента;

КонецФункции // ПроцессыАгента()

Функция ПроцессыКластера(Знач Кластер, Знач Поля)

	ПроцессыКластера = Новый Массив();

	СписокПроцессов = Кластер.Получить("Процессы").Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().РабочиеПроцессы);

	Для Каждого ТекПроцесс Из СписокПроцессов Цикл
		
		ОписаниеПроцесса = Новый Соответствие();

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если Поля.Найти(ВРег(ИмяПоля)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекПроцесс[ТекПолеОбъекта.Имя];
			Если ИмяПоля = "process" Тогда
				ОписаниеПроцесса.Вставить("process-host" , ТекПроцесс.Получить("АдресСервера"));
				ОписаниеПроцесса.Вставить("process-label", СтрШаблон("%1:%2",
				                                                     ТекПроцесс.Получить("АдресСервера"),
				                                                     ТекПроцесс.Получить("ПортСервера")));
			ИначеЕсли ИмяПоля = "started-at" Тогда
				ОписаниеПроцесса.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			КонецЕсли;
			ОписаниеПроцесса.Вставить(ИмяПоля, ЗначениеЭлемента);

		КонецЦикла;

		ПроцессыКластера.Добавить(ОписаниеПроцесса);

	КонецЦикла;

	Возврат ПроцессыКластера;
	
КонецФункции // ПроцессыКластера()

#КонецОбласти // ПолучениеДанныхПроцессов

#Область ПолучениеДанныхИБ

Функция ИБАгента(Знач Агент, Знач Поля)

	ИБАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл

		ИБКластера = ИБКластера(ТекКластер, Поля);

		Для Каждого ТекИБ Из ИБКластера Цикл
			
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("agent", СтрШаблон("%1:%2",
				                                  Агент.АдресСервераАдминистрирования(),
				                                  Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("cluster"      , ТекКластер.Ид());
				ТекИБ.Вставить("cluster-host" , ТекКластер.АдресСервера());
				ТекИБ.Вставить("cluster-port" , ТекКластер.ПортСервера());
				ТекИБ.Вставить("cluster-label",
				               СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если ДобавитьПоле(Поля, "AGENT") Тогда
				ТекИБ.Вставить("count", 1);
			КонецЕсли;
	
			ИБАгента.Добавить(ТекИБ);

		КонецЦикла;

	КонецЦикла;

	Возврат ИБАгента;

КонецФункции // ИБАгента()

Функция ИБКластера(Знач Кластер, Знач Поля)

	ИБКластера = Новый Массив();
	
	СписокИБ = Кластер.ИнформационныеБазы().Список();

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().ИнформационныеБазы);

	ПолноеОписание = Ложь;
	Для Каждого ТекПоле Из Поля Цикл
		Если НЕ ПолеОсновнойИнформации(ТекПоле) Тогда
			ПолноеОписание = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Для Каждого ТекИБ Из СписокИБ Цикл

		Если ПолноеОписание И НЕ ТекИБ.ПолноеОписание() Тогда
			ТекИБ.ОбновитьДанные(Истина);
		КонецЕсли;

		ОписаниеИБ = Новый Соответствие();

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если НЕ ДобавитьПоле(Поля, ИмяПоля) Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекИБ.Получить(ТекПолеОбъекта.Имя);
			Если ИмяПоля = "descr" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеИБ.Вставить(ИмяПоля, ЗначениеЭлемента);
		КонецЦикла;

		ИБКластера.Добавить(ОписаниеИБ);

	КонецЦикла;

	Возврат ИБКластера;
	
КонецФункции // ИБКластера()

Функция ПолеОсновнойИнформации(ИмяПоля)

	КраткиеСведения = "INFOBASE, NAME, CLUSTER, AGENT, DESCR, COUNT, _NO, _SUMMARY";

	Возврат НЕ Найти(КраткиеСведения, ВРег(ИмяПоля)) = 0;

КонецФункции // ПолеОсновнойИнформации()

Функция ДобавитьПоле(ДобавляемыеПоля, ИмяПоля)

	Если НЕ ДобавляемыеПоля.Найти("_ALL") = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти("_SUMMARY") = Неопределено И ПолеОсновнойИнформации(ИмяПоля) Тогда
		Возврат Истина;
	КонецЕсли;

	Если НЕ ДобавляемыеПоля.Найти(ВРег(ИмяПоля)) = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции // ПолеОсновнойИнформации()

#КонецОбласти // ПолучениеДанныхИБ

#Область ПолучениеДанныхСеансов

Функция СеансыАгента(Знач Агент, Знач Поля)

	СеансыАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл

		СеансыКластера = СеансыКластера(ТекКластер, Поля);

		Для Каждого ТекСеанс Из СеансыКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("agent", СтрШаблон("%1:%2",
				                                     Агент.АдресСервераАдминистрирования(),
				                                     Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("cluster"      , ТекКластер.Ид());
				ТекСеанс.Вставить("cluster-host" , ТекКластер.АдресСервера());
				ТекСеанс.Вставить("cluster-port" , ТекКластер.ПортСервера());
				ТекСеанс.Вставить("cluster-label",
				                  СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("count", 1);
			КонецЕсли;

			СеансыАгента.Добавить(ТекСеанс);

		КонецЦикла;

	КонецЦикла;

	Возврат СеансыАгента;

КонецФункции // СеансыАгента()

Функция СеансыКластера(Знач Кластер, Знач Поля)

	МеткиИБ = Новый Соответствие();
	
	СписокИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из СписокИБ Цикл
		МеткиИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	МеткиПроцессов = Новый Соответствие();
	
	СписокПроцессов = Кластер.РабочиеПроцессы().Список();
	Для Каждого ТекПроцесс Из СписокПроцессов Цикл
		ПоляПроцесса = Новый Структура("Метка, Сервер, Порт");
		ПоляПроцесса.Вставить("Сервер", ТекПроцесс.Получить("host"));
		ПоляПроцесса.Вставить("Порт"  , ТекПроцесс.Получить("port"));
		ПоляПроцесса.Вставить("Метка" , СтрШаблон("%1:%2", ПоляПроцесса.Сервер, ПоляПроцесса.Порт));

		МеткиПроцессов.Вставить(ТекПроцесс.Ид(), ПоляПроцесса);
	КонецЦикла;

	СеансыКластера = Новый Массив();

	СписокСеансов = Кластер.Получить("Сеансы").Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().Сеансы);

	Для Каждого ТекСеанс Из СписокСеансов Цикл
		
		ОписаниеСеанса = Новый Соответствие();

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если Поля.Найти(ВРег(ИмяПоля)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСеанс[ТекПолеОбъекта.Имя];
			Если ИмяПоля = "infobase" Тогда
				ОписаниеСеанса.Вставить("infobase-label", МеткиИБ[ЗначениеЭлемента]);
			ИначеЕсли ИмяПоля = "process" Тогда
				ОписаниеСеанса.Вставить("process-label", Неопределено);
				ОписаниеСеанса.Вставить("process-host" , Неопределено);
				Если НЕ МеткиПроцессов[ЗначениеЭлемента] = Неопределено Тогда
					ОписаниеСеанса.Вставить("process-label", МеткиПроцессов[ЗначениеЭлемента].Метка);
					ОписаниеСеанса.Вставить("process-host" , МеткиПроцессов[ЗначениеЭлемента].Сервер);
				КонецЕсли;
			ИначеЕсли ИмяПоля = "started-at" Тогда
				ОписаниеСеанса.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			КонецЕсли;
			ОписаниеСеанса.Вставить(ИмяПоля, ЗначениеЭлемента);

		КонецЦикла;

		СеансыКластера.Добавить(ОписаниеСеанса);

	КонецЦикла;

	Возврат СеансыКластера;
	
КонецФункции // СеансыКластера()

#КонецОбласти // ПолучениеДанныхСеансов

#Область ПолучениеДанныхСоединений

Функция СоединенияАгента(Знач Агент, Знач Поля)

	СоединенияАгента = Новый Массив();

	СписокКластеров = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из СписокКластеров Цикл

		СоединенияКластера = СоединенияКластера(ТекКластер, Поля);

		Для Каждого ТекСоединение Из СоединенияКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("agent", СтрШаблон("%1:%2",
				                                          Агент.АдресСервераАдминистрирования(),
				                                          Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("cluster"      , ТекКластер.Ид());
				ТекСоединение.Вставить("cluster-host" , ТекКластер.АдресСервера());
				ТекСоединение.Вставить("cluster-port" , ТекКластер.ПортСервера());
				ТекСоединение.Вставить("cluster-label",
				                       СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("count", 1);
			КонецЕсли;

			СоединенияАгента.Добавить(ТекСоединение);

		КонецЦикла;

	КонецЦикла;

	Возврат СоединенияАгента;

КонецФункции // СоединенияАгента()

Функция СоединенияКластера(Знач Кластер, Знач Поля)

	МеткиИБ = Новый Соответствие();
	
	СписокИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из СписокИБ Цикл
		МеткиИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	МеткиПроцессов = Новый Соответствие();
	
	СписокПроцессов = Кластер.РабочиеПроцессы().Список();
	Для Каждого ТекПроцесс Из СписокПроцессов Цикл
		ПоляПроцесса = Новый Структура("Метка, Сервер, Порт");
		ПоляПроцесса.Вставить("Сервер", ТекПроцесс.Получить("host"));
		ПоляПроцесса.Вставить("Порт"  , ТекПроцесс.Получить("port"));
		ПоляПроцесса.Вставить("Метка" , СтрШаблон("%1:%2", ПоляПроцесса.Сервер, ПоляПроцесса.Порт));

		МеткиПроцессов.Вставить(ТекПроцесс.Ид(), ПоляПроцесса);
	КонецЦикла;

	СоединенияКластера = Новый Массив();

	СписокСоединений = Кластер.Получить("Соединения").Список(, , Истина);

	ПоляОбъекта = ТипыОбъектовКластера.СвойстваОбъекта(ТипыОбъектовКластера().Соединения);

	Для Каждого ТекСоединение Из СписокСоединений Цикл
		
		ОписаниеСоединения = Новый Соответствие();

		Для Каждого ТекПолеОбъекта Из ПоляОбъекта Цикл

			ИмяПоля = ТекПолеОбъекта.ИмяРАК;

			Если Поля.Найти(ВРег(ИмяПоля)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСоединение[ТекПолеОбъекта.Имя];
			Если ИмяПоля = "infobase" Тогда
				ОписаниеСоединения.Вставить("infobase-label", МеткиИБ[ЗначениеЭлемента]);
			ИначеЕсли ИмяПоля = "process" Тогда
				ОписаниеСоединения.Вставить("process-label", МеткиПроцессов[ЗначениеЭлемента].Метка);
				ОписаниеСоединения.Вставить("process-host" , МеткиПроцессов[ЗначениеЭлемента].Сервер);
			ИначеЕсли ИмяПоля = "connected-at" Тогда
				ОписаниеСоединения.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			ИначеЕсли ИмяПоля = "application" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеСоединения.Вставить(ИмяПоля, ЗначениеЭлемента);

		КонецЦикла;

		СоединенияКластера.Добавить(ОписаниеСоединения);

	КонецЦикла;

	Возврат СоединенияКластера;
	
КонецФункции // СоединенияКластера()

#КонецОбласти // ПолучениеДанныхСоединений

#Область СлужебныеПроцедурыИФункции

// Функция - создает, устанавливает настройки и возвращает объект управления кластером 1С
//
// Параметры:
//   ПараметрыПодключения    - Соответствие   - настройки подключения к агентам администрирования
//   Агент                   - Строка         - адрес подключения к агенту администрирования в виде <адрес>:<порт>
//
// Возвращаемое значение:
//   УправлениеКластером1С     - объект управления кластером 1С
//
Функция ИнициализироватьАгента(ПараметрыПодключения, Агент)
	
	ПараметрыПоУмолчанию = ПараметрыПодключения["__default"];
	ПараметрыПоИмени = ПараметрыПодключения[Агент];

	АдресRAS      = "localhost:1545";
	ВерсияRAC     = "8.3";
	Администратор = Новый Структура("Администратор, Пароль", "", "");

	Если НЕ ПараметрыПоУмолчанию = Неопределено Тогда
		Если НЕ ПараметрыПоУмолчанию["ras"] = Неопределено Тогда
			АдресRAS = ПараметрыПоУмолчанию["ras"];
		КонецЕсли;
		Если НЕ ПараметрыПоУмолчанию["rac"] = Неопределено Тогда
			ВерсияRAC = ПараметрыПоУмолчанию["rac"];
		КонецЕсли;

		Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_name"]) Тогда
			Администратор.Администратор = ПараметрыПоУмолчанию["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_pwd"]) Тогда
				Администратор.Пароль = ПараметрыПоУмолчанию["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если НЕ ПараметрыПоИмени = Неопределено Тогда
		Если НЕ ПараметрыПоИмени["ras"] = Неопределено Тогда
			АдресRAS = ПараметрыПоИмени["ras"];
		КонецЕсли;
		Если НЕ ПараметрыПоИмени["rac"] = Неопределено Тогда
			ВерсияRAC = ПараметрыПоИмени["rac"];
		КонецЕсли;

		Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_name"]) Тогда
			Администратор.Администратор = ПараметрыПоИмени["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_pwd"]) Тогда
				Администратор.Пароль = ПараметрыПоИмени["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	УправлениеКластером = Новый УправлениеКластером1С(ВерсияRAC, АдресRAS, Администратор);

	Если НЕ (ПараметрыПоИмени = Неопределено ИЛИ ПараметрыПоИмени["cluster"] = Неопределено) Тогда
		Кластеры = УправлениеКластером.Кластеры().Список();
		Для Каждого ТекКластер Из Кластеры Цикл
			УстановитьПараметрыКластера(ПараметрыПоИмени["cluster"], ТекКластер);
		КонецЦикла;
	КонецЕсли;

	Возврат УправлениеКластером;

КонецФункции // ИнициализироватьАгента()

// Процедура - устанавливает параметры кластера из настроек
//
// Параметры:
//   ПараметрыКластеров - Соответствие   - настройки кластеров
//   Кластер            - Кластер        - объект кластера 1С
//
Процедура УстановитьПараметрыКластера(ПараметрыКластеров, Кластер)
	
	ПараметрыПоУмолчанию = ПараметрыКластеров["__default"];
	МеткаКластера = СтрШаблон("%1:%2", Кластер.АдресСервера(), Кластер.ПортСервера());
	ПараметрыПоИмени     = ПараметрыКластеров[МеткаКластера];

	Администратор = "";
	Пароль        = "";

	Если НЕ ПараметрыПоУмолчанию = Неопределено Тогда
		Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_name"]) Тогда
			Администратор = ПараметрыПоУмолчанию["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_pwd"]) Тогда
				Пароль = ПараметрыПоУмолчанию["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если НЕ ПараметрыПоИмени = Неопределено Тогда
		Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_name"]) Тогда
			Администратор = ПараметрыПоИмени["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_pwd"]) Тогда
				Пароль = ПараметрыПоИмени["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Кластер.УстановитьАдминистратора(Администратор, Пароль);

	Если НЕ (ПараметрыПоИмени = Неопределено ИЛИ ПараметрыПоИмени["infobase"] = Неопределено) Тогда
		СписокИБ = Кластер.ИнформационныеБазы().Список();
		Для Каждого ТекИБ Из СписокИБ Цикл
			УстановитьПараметрыИБ(ПараметрыПоИмени["infobase"], ТекИБ);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // УстановитьПараметрыКластера()

// Процедура - устанавливает параметры информационной базы из настроек
//
// Параметры:
//   ПараметрыИБ   - Соответствие        - настройки информационных баз
//   ИБ            - ИнформационнаяБаза  - объект информационной базы 1С
//
Процедура УстановитьПараметрыИБ(ПараметрыИБ, ИБ)
	
	ПараметрыПоУмолчанию = ПараметрыИБ["__default"];
	ПараметрыПоИмени     = ПараметрыИБ[ИБ.Имя()];

	Администратор = "";
	Пароль        = "";

	Если НЕ ПараметрыПоУмолчанию = Неопределено Тогда
		Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_name"]) Тогда
			Администратор = ПараметрыПоУмолчанию["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоУмолчанию["admin_pwd"]) Тогда
				Пароль = ПараметрыПоУмолчанию["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если НЕ ПараметрыПоИмени = Неопределено Тогда
		Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_name"]) Тогда
			Администратор = ПараметрыПоИмени["admin_name"];
			Если ЗначениеЗаполнено(ПараметрыПоИмени["admin_pwd"]) Тогда
				Пароль = ПараметрыПоИмени["admin_pwd"];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	ИБ.УстановитьАдминистратора(Администратор, Пароль);

КонецПроцедуры // УстановитьПараметрыИБ()

Функция ТипыОбъектовКластера()

	Возврат Перечисления.РежимыАдминистрирования;

КонецФункции // ТипыОбъектовКластера()

#КонецОбласти // СлужебныеПроцедурыИФункции
