
&HTTPMethod("GET")
Функция list() Экспорт

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь, ЗапросHTTP.СтрокаЗапроса, "process", "list");

	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Поля = "_all";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ПараметрыЗапроса);

	Первые = ОбщегоНазначения.ВыборкаПервыхИзПараметровЗапроса(ПараметрыЗапроса);

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	Результат = ОбщегоНазначения.ДанныеВJSON(ПодключенияКАгентам.Процессы(Поля, Фильтр, Первые, Истина));

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамер(ЗапросHTTP.Путь, ЗапросHTTP.СтрокаЗапроса, "process", "get");

	АдресСервера = Неопределено;
	ПортСервера  = Неопределено;
	ИмяПараметра = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		АдресСервера = ЗначенияМаршрута.Получить("host");
		ПортСервера  = ЗначенияМаршрута.Получить("port");
		ИмяПараметра = ЗначенияМаршрута.Получить("parameter");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = "json";
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ПараметрыЗапроса["format"];
	КонецЕсли;

	Поля = "_all";
	Если НЕ ПараметрыЗапроса["field"] = Неопределено Тогда
		Поля = ПараметрыЗапроса["field"];
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	Данные = ПодключенияКАгентам.Процесс(АдресСервера, ПортСервера, Поля, Истина);
	
	Если ЗначениеЗаполнено(ИмяПараметра) Тогда
		Если Данные = Неопределено Тогда
			ЗначениеПараметра = ПодключенияКАгентам.ПустойОбъектКластера("process", Поля)[ИмяПараметра];
		Иначе
			ЗначениеПараметра = Данные[ИмяПараметра];
		КонецЕсли;
		Если ТипЗнч(ЗначениеПараметра) = Тип("Дата") Тогда
			ЗначениеПараметра = Формат(ЗначениеПараметра, "ДФ=yyyy-MM-ddThh:mm:ss");
		КонецЕсли;
		Результат = СтрШаблон("%1=%2", ИмяПараметра, ЗначениеПараметра);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Данные);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Возврат Содержимое(Результат);

КонецФункции // get()
