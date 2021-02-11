
// Функция - читает указанный макет JSON и возвращает содержимое в виде структуры/массива
//
// Параметры:
//	ПутьКМакету    - Строка   - путь к макету json
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные данные из макета 
//
Функция ПрочитатьДанныеИзМакетаJSON(Знач ПутьКМакету, Знач ВСоответствие = Ложь) Экспорт

	Чтение = Новый ЧтениеJSON();

	ПутьКМакету = ПолучитьМакет(ПутьКМакету);
	
	Чтение.ОткрытьФайл(ПутьКМакету, КодировкаТекста.UTF8);
	
	Возврат ПрочитатьJSON(Чтение, ВСоответствие);

КонецФункции // ПрочитатьДанныеИзМакетаJSON()

// Функция - читает данные из тела HTTP-запроса
//
// Параметры:
//	ЗапросHTTP    - ЗапросHTTPВходящий   - HTTP-запрос, тело которого читаем
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные данные из тела запроса 
//
Функция ПрочитатьДанныеТелаЗапроса(ЗапросHTTP) Экспорт

	Заголовки = ЗапросHTTP.Заголовки;

	ДанныеТелаПоток = ЗапросHTTP.ПолучитьТелоКакПоток();

	Чтение = Новый ЧтениеДанных(ДанныеТелаПоток);
	РезультатЧтения = Чтение.Прочитать();
	Данные = РезультатЧтения.ПолучитьДвоичныеДанные();
	
	Чтение = Новый ЧтениеJSON();
	Чтение.УстановитьСтроку(ПолучитьСтрокуИзДвоичныхДанных(Данные));

	Данные = ПрочитатьJSON(Чтение);

	Чтение.Закрыть();

	Возврат Данные;

КонецФункции // ПрочитатьДанныеТелаЗапроса()

// Функция преобразует переданный текст вывода команды в массив соответствий
// элементы массива создаются по блокам текста, разделенным пустой строкой
// пары <ключ, значение> структуры получаются для каждой строки с учетом разделителя ":"
//   
// Параметры:
//   ВыводКоманды            - Строка            - текст для разбора
//   
// Возвращаемое значение:
//    Массив (Соответствие) - результат разбора
//
Функция РазобратьВыводКоманды(Знач ВыводКоманды)
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ВыводКоманды);

	МассивРезультатов = Новый Массив();
	Описание = Новый Соответствие();

	Для й = 1 По Текст.КоличествоСтрок() Цикл

		ТекстСтроки = Текст.ПолучитьСтроку(й);
		
		ПозРазделителя = СтрНайти(ТекстСтроки, ":");
		
		Если НЕ ЗначениеЗаполнено(ТекстСтроки) Тогда
			Если й = 1 Тогда
				Продолжить;
			КонецЕсли;
			МассивРезультатов.Добавить(Описание);
			Описание = Новый Соответствие();
			Продолжить;
		КонецЕсли;

		Если ПозРазделителя = 0 Тогда
			Описание.Вставить(СокрЛП(ТекстСтроки), "");
		Иначе
			Описание.Вставить(СокрЛП(Лев(ТекстСтроки, ПозРазделителя - 1)), СокрЛП(Сред(ТекстСтроки, ПозРазделителя + 1)));
		КонецЕсли;
		
	КонецЦикла;

	Если Описание.Количество() > 0 Тогда
		МассивРезультатов.Добавить(Описание);
	КонецЕсли;
	
	Если МассивРезультатов.Количество() = 1 И ТипЗнч(МассивРезультатов[0]) = Тип("Строка") Тогда
		Возврат МассивРезультатов[0];
	КонецЕсли;

	Возврат МассивРезультатов;

КонецФункции // РазобратьВыводКоманды()

// Функция - получает значение настройки из соответствия или структуры по ключу без учета регистра ключа
//   
// Параметры:
//   Настройка      - Строка                    - ключ (имя) настройки
//   ВсеНастройки   - Структура, Соответствие   - контейнер настроек
//   ПоУмолчанию    - Произвольный              - значение настройки по умолчанию
//                                                возвращается если контейнер не содержит указанную настройку
//   
// Возвращаемое значение:
//    Произвольный   - значение настройки или значение по умолчанию
//
Функция ПолучитьЗначениеНастройки(Настройка, ВсеНастройки, ПоУмолчанию = Неопределено) Экспорт
	
	ЭтоНастройки = (ТипЗнч(ВсеНастройки) = Тип("Соответствие")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("ФиксированноеСоответствие")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("Структура")
	            ИЛИ ТипЗнч(ВсеНастройки) = Тип("ФиксированнаяСтруктура"));

	Если НЕ ЭтоНастройки Тогда
		Возврат ПоУмолчанию;
	КонецЕсли;

	Для Каждого ТекНастройка Из ВсеНастройки Цикл
		Если НРег(ТекНастройка.Ключ) = НРег(Настройка) Тогда
			Возврат ТекНастройка.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПоУмолчанию;
	
КонецФункции // ПолучитьЗначениеНастройки()

// Функция - возвращает пустой GUID
//
// Возвращаемое значение:
//    Строка     - "00000000-0000-0000-0000-000000000000"
//
Функция ПустойГУИД() Экспорт

	Возврат "00000000-0000-0000-0000-000000000000";

КонецФункции // ПустойГУИД()

// Процедура - убирает в строке начальные и конечные кавычки
//
// Параметры:
//	Значение    - Строка     - строка для обработки
//
// Возвращаемое значение:
//    Строка     - строка без кавычек
//
Процедура УбратьКавычки(Значение) Экспорт

	Если Лев(Значение, 1) = """"  И Прав(Значение, 1) = """" Тогда
		Значение = Сред(Значение, 2, СтрДлина(Значение) - 2);
	КонецЕсли;

КонецПроцедуры // УбратьКавычки()

// Процедура - выполняет преобразование переданных данных в JSON
//
// Параметры:
//    Данные       - Произвольный     - данные для преобразования
//
// Возвращаемое значение:
//    Строка     - результат преобразованияданные для преобразования
//
Функция ДанныеВJSON(Знач Данные) Экспорт
	
	Запись = Новый ЗаписьJSON();
	
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));

	Попытка
		ЗаписатьJSON(Запись, Данные);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Возврат Запись.Закрыть();
	
КонецФункции // ДанныеВJSON()

// Функция возвращает структуру операторов сравнения
//
// Возвращаемое значение:
//    ФиксированнаяСтруктура - операторы сравнения
//
Функция ОператорыСравнения() Экспорт

	ОператорыСравнения = Новый Структура();

	ОператорыСравнения.Вставить("Равно"         , "EQ");
	ОператорыСравнения.Вставить("НеРавно"       , "NEQ");
	ОператорыСравнения.Вставить("Больше"        , "GT");
	ОператорыСравнения.Вставить("БольшеИлиРавно", "GTE");
	ОператорыСравнения.Вставить("Меньше"        , "LT");
	ОператорыСравнения.Вставить("МеньшеИлиРавно", "LTE");

	Возврат Новый ФиксированнаяСтруктура(ОператорыСравнения);

КонецФункции // ОператорыСравнения()

// Функция возвращает соответствия псевдонимов операторам сравнения
//
// Возвращаемое значение:
//    ФиксированноеСоответствие - псевдонимы операторов сравнения
//
Функция ПсевдонимыОператоровСравнения() Экспорт

	ОператорыСравнения = ОператорыСравнения();

	ПсевдонимыОператоров = Новый Соответствие();

	Для Каждого ТекЭлемент Из ОператорыСравнения Цикл
		ПсевдонимыОператоров.Вставить(ТекЭлемент.Значение, ТекЭлемент.Значение);
	КонецЦикла;

	ПсевдонимыОператоров.Вставить("EQUAL"             , ОператорыСравнения.Равно);
	ПсевдонимыОператоров.Вставить("NOTEQUAL"          , ОператорыСравнения.НеРавно);
	ПсевдонимыОператоров.Вставить("GREATERTHEN"       , ОператорыСравнения.Больше);
	ПсевдонимыОператоров.Вставить("GREATERTHENOREQUAL", ОператорыСравнения.БольшеИлиРавно);
	ПсевдонимыОператоров.Вставить("LESSTHEN"          , ОператорыСравнения.Меньше);
	ПсевдонимыОператоров.Вставить("LESSTHENOREQUAL"   , ОператорыСравнения.МеньшеИлиРавно);

	Возврат Новый ФиксированноеСоответствие(ПсевдонимыОператоров);

КонецФункции // ПсевдонимыОператоровСравнения()

// Функция получает список полей из строки или массива
//   
// Параметры:
//   Поля                - Массив, Строка  - список полей
//   ВсеПоля             - Строка          - строковое представления добавления всех полей
//
// Возвращаемое значение:
//    Массив из Строка   - список полей, если параметр не Массив или Строка,
//                         то результат содержит единственный элемент со значением параметра "ВсеПоля"
//
Функция СписокПолей(Знач Поля, Знач ВсеПоля = "_ALL") Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		СписокПолей = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По СписокПолей.ВГраница() Цикл
			СписокПолей[й] = ВРег(СокрЛП(СписокПолей[й]));
		КонецЦикла;
	ИначеЕсли ТипЗнч(Поля) = Тип("Массив") Тогда
		СписокПолей = Поля;
	Иначе
		СписокПолей = Новый Массив();
		СписокПолей.Добавить(ВРег(ВсеПоля));
	КонецЕсли;

	Возврат СписокПолей;

КонецФункции // СписокПолей()

// Функция выполняет сравнение значений
//   
// Параметры:
//   ЛевоеЗначение      - Произвольный  - левое значение сравнения
//   Оператор           - Строка        - оператор сравнения
//   ПравоеЗначение     - Произвольный  - правое значение сравнения
//   РегистроНезависимо - Булево        - Истина - при сравнении на (не)равенство
//                                        не будет учитываться регистр сравниваемых значений
//
// Возвращаемое значение:
//    Булево            - Истина - сравнение истино
//
Функция СравнитьЗначения(Знач ЛевоеЗначение,
	                     Знач Оператор,
	                     Знач ПравоеЗначение,
	                     Знач РегистроНезависимо = Истина) Экспорт

	ОператорыСравнения = ОператорыСравнения();

	Результат = Ложь;

	Если РегистроНезависимо И (Оператор = ОператорыСравнения.Равно ИЛИ Оператор = ОператорыСравнения.НеРавно) Тогда
		ЛевоеЗначение  = ВРег(ЛевоеЗначение);
		ПравоеЗначение = ВРег(ПравоеЗначение);
	КонецЕсли;

	Если НЕ ТипЗнч(ЛевоеЗначение) = ТипЗнч(ПравоеЗначение) Тогда
		Если ТипЗнч(ЛевоеЗначение) = Тип("Число") Тогда
			ПравоеЗначение = Число(ПравоеЗначение);
		ИначеЕсли ТипЗнч(ЛевоеЗначение) = Тип("Дата") Тогда
			ПравоеЗначение = ПрочитатьДатуJSON(ПравоеЗначение, ФорматДатыJSON.ISO);
		ИначеЕсли ТипЗнч(ЛевоеЗначение) = Тип("Булево") Тогда
			ПравоеЗначение = ?(ВРег(ПравоеЗначение) = "TRUE" ИЛИ ВРег(ПравоеЗначение) = "ИСТИНА", Истина, Ложь);
		Иначе
			ЛевоеЗначение  = Строка(ЛевоеЗначение);
			ПравоеЗначение = Строка(ПравоеЗначение);
		КонецЕсли;
	КонецЕсли;
			
	
	Если Оператор = ОператорыСравнения.Равно И ЛевоеЗначение = ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.НеРавно И НЕ ЛевоеЗначение = ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.Больше И ЛевоеЗначение > ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.БольшеИлиРавно И ЛевоеЗначение >= ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.Меньше И ЛевоеЗначение < ПравоеЗначение Тогда
		Результат = Истина;
	ИначеЕсли Оператор = ОператорыСравнения.МеньшеИлиРавно И ЛевоеЗначение <= ПравоеЗначение Тогда
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;

КонецФункции // СравнитьЗначения()

// Функция проверяет соответствие значения указанному набору сравнений (фильтру)
// результаты сравнений объединяются по "И"
//   
// Параметры:
//   Значение           - Произвольный         - проверяемое значение
//   Фильтр             - Массив из Структура  - набор сравнений (фильтр)
//       * Оператор         - Строка               - оператор сравнения
//       * Значение         - Произвольный         - значение для сравнения
//   РегистроНезависимо - Булево               - Истина - при сравнении на (не)равенство
//   
// Возвращаемое значение:
//    Булево            - Истина - значение соответствует фильтру
//
Функция ЗначениеСоответствуетФильтру(Знач Значение, Знач Фильтр, Знач РегистроНезависимо = Истина) Экспорт

	Результат = Истина;

	Если НЕ (ЗначениеЗаполнено(Фильтр) И ТипЗнч(Фильтр) = Тип("Массив")) Тогда
		Возврат Результат;
	КонецЕсли;

	Для Каждого ТекСравнение Из Фильтр Цикл
		Результат = СравнитьЗначения(Значение, ТекСравнение.Оператор, ТекСравнение.Значение, РегистроНезависимо);
		Если НЕ Результат Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // ЗначениеСоответствуетЭлементуФильтра()

// Функция проверяет соответствие значений полей объекта указанному набору сравнений (фильтру)
// результаты сравнений объединяются по "И"
//   
// Параметры:
//   Объект             - Соответствие         - проверяемый объект
//   Фильтр             - Массив из Структура  - набор сравнений (фильтр)
//       * Оператор         - Строка               - оператор сравнения
//       * Значение         - Произвольный         - значение для сравнения
//   РегистроНезависимо - Булево               - Истина - при сравнении на (не)равенство
//   
// Возвращаемое значение:
//    Булево            - Истина - значения полей объекта соответствует фильтру
//
Функция ОбъектСоответствуетФильтру(Объект, Фильтр, РегистроНезависимо = Истина) Экспорт

	Результат = Истина;

	Если НЕ (ЗначениеЗаполнено(Фильтр) И ТипЗнч(Фильтр) = Тип("Соответствие")) Тогда
		Возврат Результат;
	КонецЕсли;

	Для Каждого ТекЭлементФильтра Из Фильтр Цикл
		Если Объект[ТекЭлементФильтра.Ключ] = Неопределено Тогда
			Результат = Ложь;
			Прервать;
		КонецЕсли;
		Результат = ЗначениеСоответствуетФильтру(Объект[ТекЭлементФильтра.Ключ], ТекЭлементФильтра.Значение);
		Если НЕ Результат Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;

КонецФункции // ОбъектСоответствуетФильтру()

// Функция выделяет фильтр из параметров запроса
//   
// Параметры:
//   ПараметрыЗапроса       - Соответствие       - параметры HTTP-запроса
//   
// Возвращаемое значение:
//    Соответствие                                   - фильтр
//        <имя поля>      - Массив из Структура      - фильтр для поля <имя поля>
//           * Оператор         - Строка                 - оператор сравнения
//           * Значение         - Произвольный           - значение для сравнения
//
Функция ФильтрИзПараметровЗапроса(ПараметрыЗапроса) Экспорт

	Фильтр = Новый Соответствие();
	ОператорыСравнения = ОбщегоНазначения.ОператорыСравнения();
	ПсевдонимыОператоровСравнения = ОбщегоНазначения.ПсевдонимыОператоровСравнения();

	Для Каждого ТекЭлемент Из ПараметрыЗапроса Цикл
		Если Лев(ВРег(ТекЭлемент.Ключ), 7) = ВРег("filter_") Тогда
			ИмяПоля = Сред(ТекЭлемент.Ключ, 8);
			Оператор = ОбщегоНазначения.ОператорыСравнения().Равно;
			ОкончаниеОператора = Найти(ИмяПоля, "_");
			Если ОкончаниеОператора > 0 Тогда
				ПсевдонимОператора = ВРег(Сред(ИмяПоля, 1, ОкончаниеОператора - 1));
				Если НЕ ПсевдонимыОператоровСравнения.Получить(ПсевдонимОператора) = Неопределено Тогда
					Оператор = ПсевдонимыОператоровСравнения[ПсевдонимОператора];
					ИмяПоля = Сред(ИмяПоля, ОкончаниеОператора + 1);
				КонецЕсли;
			КонецЕсли;

			Если Фильтр[ИмяПоля] = Неопределено Тогда
				Фильтр.Вставить(ИмяПоля, Новый Массив());
			КонецЕсли;

			Фильтр[ИмяПоля].Добавить(Новый Структура("Оператор, Значение", Оператор, ТекЭлемент.Значение));
		КонецЕсли;
	КонецЦикла;

	Возврат Фильтр;

КонецФункции // ФильтрИзПараметровЗапроса()

Функция ВыборкаПервыхИзПараметровЗапроса(ПараметрыЗапроса) Экспорт

	Первые = Неопределено;

	Для Каждого ТекЭлемент Из ПараметрыЗапроса Цикл
		Если ВРег(ТекЭлемент.Ключ) = "TOP" Тогда
			Первые = Новый Структура("ИмяПоля, Количество");
			Первые.ИмяПоля = "_value";
			Первые.Количество = Число(ТекЭлемент.Значение);
		ИначеЕсли Лев(ВРег(ТекЭлемент.Ключ), 4) = "TOP_" Тогда
			Первые = Новый Структура("ИмяПоля, Количество");
			Первые.ИмяПоля = Сред(ТекЭлемент.Ключ, 5);
			Первые.Количество = Число(ТекЭлемент.Значение);
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Первые;

КонецФункции // ВыборкаПервыхИзПараметровЗапроса()

Функция ПервыеПоЗначениюПоля(Элементы, ИмяПоля, Количество) Экспорт

	ТабСортировки = Новый ТаблицаЗначений();
	ТабСортировки.Колонки.Добавить("ЗначениеСортировки");
	ТабСортировки.Колонки.Добавить("Элемент");

	Для Каждого ТекЭлемент Из Элементы Цикл
		НоваяСтрока = ТабСортировки.Добавить();
		НоваяСтрока.ЗначениеСортировки = ТекЭлемент[ИмяПоля];
		НоваяСтрока.Элемент            = ТекЭлемент;
	КонецЦикла;

	ТабСортировки.Сортировать("ЗначениеСортировки УБЫВ");

	Количество = Мин(Количество, ТабСортировки.Количество());

	Результат = Новый Массив();

	Для й = 0 По Количество - 1 Цикл
		Результат.Добавить(ТабСортировки[й].Элемент);
	КонецЦикла;

	Возврат Результат;

КонецФункции // ПервыеПоЗначениюПоля()
