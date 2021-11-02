// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/hirac/
// ----------------------------------------------------------

&HTTPMethod("GET")
Функция list() Экспорт

	ТипОбъектовКластера = Сред(ЗапросHTTP.Путь, 2);
	ТипОбъектовКластера = Лев(ТипОбъектовКластера, Найти(ТипОбъектовКластера, "/") - 1);

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь, ЗапросHTTP.СтрокаЗапроса, ТипОбъектовКластера, "list");

	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = ОбщегоНазначения.ФорматыРезультата().json;
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ВРег(ПараметрыЗапроса["format"]);
	КонецЕсли;

	Поля = "_all";
	Если ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.ИнформационныеБазы Тогда
		Поля = "_summary";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Соединения Тогда
		Поля = "_summary";
	КонецЕсли;
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ПараметрыЗапроса);

	Сортировка = "";
	Если НЕ ПараметрыЗапроса["order"] = Неопределено Тогда
		Сортировка = ПараметрыЗапроса["order"];
	КонецЕсли;

	ПервыеКоличество = 0;
	Если НЕ ПараметрыЗапроса["top"] = Неопределено Тогда
		ПервыеКоличество = Число(ПараметрыЗапроса["top"]);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	ОбъектыКластера = ПодключенияКАгентам.ОбъектыКластера(ТипОбъектовКластера, Истина, Поля, Фильтр);

	Если ЗначениеЗаполнено(Сортировка) Тогда
		ОбщегоНазначения.СортироватьДанные(ОбъектыКластера, Сортировка);
	КонецЕсли;

	Если ПервыеКоличество > 0 Тогда
		ОбъектыКластера = ОбщегоНазначения.Первые(ОбъектыКластера, ПервыеКоличество);
	КонецЕсли;

	Если Формат = ОбщегоНазначения.ФорматыРезультата().prometheus Тогда
		Результат = ФорматСпискаPrometheus(ОбъектыКластера, ТипОбъектовКластера);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().plain Тогда
		Результат = ФорматСпискаPlain(ОбъектыКластера);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(ОбъектыКластера);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	ТипОбъектовКластера = Сред(ЗапросHTTP.Путь, 2);
	ТипОбъектовКластера = Лев(ТипОбъектовКластера, Найти(ТипОбъектовКластера, "/") - 1);

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь,
	                                            ЗапросHTTP.СтрокаЗапроса,
	                                            ТипОбъектовКластера,
	                                            "get");

	Ид = Неопределено;
	ИмяСвойства = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		Ид = ЗначенияМаршрута.Получить("id");
		ИмяСвойства = ЗначенияМаршрута.Получить("property");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = ОбщегоНазначения.ФорматыРезультата().json;
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ВРег(ПараметрыЗапроса["format"]);
	КонецЕсли;

	Поля = "_all";
	Если ЗначениеЗаполнено(ИмяСвойства) Тогда
		Поля = ИмяСвойства;
	ИначеЕсли НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Условия = Новый Массив();
	Условия.Добавить(Новый Структура("Оператор, Значение", ОбщегоНазначения.ОператорыСравнения().Равно, Ид));

	Фильтр = Новый Соответствие();
	Если ОбщегоНазначения.ЭтоGUID(Ид) Тогда
		Фильтр.Вставить("id", Условия);
	Иначе
		Фильтр.Вставить("label", Условия);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	ОбъектыКластера = ПодключенияКАгентам.ОбъектыКластера(ТипОбъектовКластера, Истина, Поля, Фильтр);

	Если ОбъектыКластера.Количество() = 0 Тогда
		Результат = Неопределено;
	Иначе
		Результат = ОбъектыКластера[0];
	КонецЕсли;

	Если ЗначениеЗаполнено(ИмяСвойства) Тогда
		Если Результат = Неопределено Тогда
			ЗначениеСвойства = ПодключенияКАгентам.ПустойОбъектКластера(ТипОбъектовКластера, Поля)[ИмяСвойства];
		Иначе
			ЗначениеСвойства = Результат[ИмяСвойства];
		КонецЕсли;
		Если ТипЗнч(ЗначениеСвойства) = Тип("Дата") Тогда
			ЗначениеСвойства = Формат(ЗначениеСвойства, "ДФ=yyyy-MM-ddThh:mm:ss");
		КонецЕсли;
		Результат = Новый Соответствие();
		Результат.Вставить(ИмяСвойства, ЗначениеСвойства);
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Результат) Тогда
		ОписаниеОшибки = СтрШаблон("Не удалось получить описание объекта кластера %1 по идентификатору ""%2""",
		                           ТипОбъектовКластера,
		                           Ид);
		Результат = Новый Соответствие();
		Результат.Вставить("error", Истина);
		Результат.Вставить("description", ОписаниеОшибки);
	КонецЕсли;

	Если Формат = ОбщегоНазначения.ФорматыРезультата().prometheus Тогда
		Результат = ФорматОбъектаPrometheus(Результат, ТипОбъектовКластера);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().plain Тогда
		Результат = ФорматОбъектаPlain(Результат);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().valueOnly Тогда
		Результат = ФорматОбъектаPlain(Результат, Истина);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Результат);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // get()

Функция ФорматСпискаPrometheus(Данные, ТипОбъектовКластера)

	Текст = Новый Массив();

	ЗаголовокЭлемента = СтрЗаменить(ТипОбъектовКластера, "-", "_");

	ОписаниеЭлемента = "";

	Текст.Добавить(СтрШаблон("# HELP %1 %2", ЗаголовокЭлемента, ОписаниеЭлемента));
	Текст.Добавить(СтрШаблон("# TYPE %1 gauge", ЗаголовокЭлемента));

	Для Каждого ТекЭлемент Из Данные Цикл

		ЗначенияИзмеренийСтрокой = "";
		ЗначениеЭлемента = 1;
		Для Каждого ТекПоле Из ТекЭлемент Цикл
			Если ВРег(ТекПоле.Ключ) = "COUNT" Тогда
				Продолжить;
			КонецЕсли;
			
			ЗначениеИзмерения = ТекПоле.Значение;
			Если ТипЗнч(ЗначениеИзмерения) = Тип("Дата") Тогда
				ЗначениеИзмерения = Формат(ЗначениеИзмерения, "ДФ=yyyy-MM-ddThh:mm:ss");
			КонецЕсли;
			ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
										?(ЗначенияИзмеренийСтрокой = "", "", ",") +
										СтрШаблон("%1=""%2""", СтрЗаменить(ТекПоле.Ключ, "-", "_"), ЗначениеИзмерения);
		КонецЦикла;
		
		Текст.Добавить(СтрШаблон("%1{%2} %3",
		                         ЗаголовокЭлемента,
		                         ЗначенияИзмеренийСтрокой,
		                         ЗначениеЭлемента));
	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматСпискаPrometheus()

Функция ФорматСпискаPlain(Данные)

	Текст = Новый Массив();

	Для Каждого ТекЭлемент Из Данные Цикл

		Для Каждого ТекПоле Из ТекЭлемент Цикл
		
			ЗначениеЭлемента = ТекПоле.Значение;
			
			Если НЕ ЗначениеЗаполнено(ЗначениеЭлемента) Тогда
				ЗначениеЭлемента = "";
			КонецЕсли;
			
			Если ТипЗнч(ЗначениеЭлемента) = Тип("Число") Тогда
				ЗначениеЭлемента = Формат(ЗначениеЭлемента, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;

			Текст.Добавить(СтрШаблон("%1=%2", ТекПоле.Ключ, ЗначениеЭлемента));

		КонецЦикла;

		Текст.Добавить(" ");

	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматСпискаPlain()

Функция ФорматОбъектаPrometheus(Данные, ТипОбъектовКластера)

	Текст = Новый Массив();

	ЗаголовокЭлемента = СтрЗаменить(ТипОбъектовКластера, "-", "_");

	ОписаниеЭлемента = "";

	Текст.Добавить(СтрШаблон("# HELP %1 %2", ЗаголовокЭлемента, ОписаниеЭлемента));
	Текст.Добавить(СтрШаблон("# TYPE %1 gauge", ЗаголовокЭлемента));

	ЗначенияИзмеренийСтрокой = "";
	ЗначениеЭлемента = 1;
	Для Каждого ТекПоле Из Данные Цикл

		Если ВРег(ТекПоле.Ключ) = "COUNT" Тогда
			Продолжить;
		КонецЕсли;

		ЗначениеИзмерения = ТекПоле.Значение;
		Если ТипЗнч(ЗначениеИзмерения) = Тип("Дата") Тогда
			ЗначениеИзмерения = Формат(ЗначениеИзмерения, "ДФ=yyyy-MM-ddThh:mm:ss");
		КонецЕсли;
		ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
									?(ЗначенияИзмеренийСтрокой = "", "", ",") +
									СтрШаблон("%1=""%2""", СтрЗаменить(ТекПоле.Ключ, "-", "_"), ЗначениеИзмерения);
	КонецЦикла;

	Текст.Добавить(СтрШаблон("%1{%2} %3",
	                               ЗаголовокЭлемента,
	                               ЗначенияИзмеренийСтрокой,
	                               ЗначениеЭлемента));

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматОбъектаPrometheus()

Функция ФорматОбъектаPlain(Данные, ТолькоЗначение = Ложь)

	Текст = Новый Массив();

	Для Каждого ТекПоле Из Данные Цикл
		
		ЗначениеЭлемента = ТекПоле.Значение;
		
		Если НЕ ЗначениеЗаполнено(ЗначениеЭлемента) Тогда
			ЗначениеЭлемента = "";
		КонецЕсли;
		
		Если ТипЗнч(ЗначениеЭлемента) = Тип("Число") Тогда
			ЗначениеЭлемента = Формат(ЗначениеЭлемента, "ЧРД=.; ЧН=; ЧГ=0");
		КонецЕсли;

		Если ТолькоЗначение И Данные.Количество() = 1 Тогда
			Текст.Добавить(ЗначениеЭлемента);
		Иначе
			Текст.Добавить(СтрШаблон("%1=%2", ТекПоле.Ключ, ЗначениеЭлемента));
		КонецЕсли;

	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматОбъектаPlain()

