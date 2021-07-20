
#Использовать "model"

Процедура ПриНачалеРаботыСистемы()

	ИспользоватьМаршруты("ОпределениеМаршрутов");

КонецПроцедуры // ПриНачалеРаботыСистемы()

Процедура ОпределениеМаршрутов(КоллекцияМаршрутов)

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "counter");
	ПараметрыМаршрута.Вставить("action", "list");
	
	КоллекцияМаршрутов.Добавить("counter_list", "counter/list", ПараметрыМаршрута);
	КоллекцияМаршрутов.Добавить("counter_type_list", "counter/{type}/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "counter");
	ПараметрыМаршрута.Вставить("action", "get");
	
	КоллекцияМаршрутов.Добавить("counter", "counter/{type}/{counter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "cluster");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("cluster", "cluster/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "cluster");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("cluster_params", "cluster/{host}/{port}/{parameter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "server");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("server", "server/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "server");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("server_params", "server/{host}/{port}/{parameter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "process");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("process", "process/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "process");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("process_params", "process/{host}/{port}/{parameter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "infobase");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("infobase", "infobase/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "infobase");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("infobase_params", "infobase/{infobase}/{parameter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "session");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("session", "session/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "session");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("session_params", "session/{infobase}/{session}/{parameter?}", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "connection");
	ПараметрыМаршрута.Вставить("action", "list");

	КоллекцияМаршрутов.Добавить("connection", "connection/list", ПараметрыМаршрута);

	ПараметрыМаршрута = Новый Соответствие();
	ПараметрыМаршрута.Вставить("controller", "connection");
	ПараметрыМаршрута.Вставить("action", "get");

	КоллекцияМаршрутов.Добавить("connection_params", "connection/{infobase}/{connection}/{parameter?}", ПараметрыМаршрута);

	КоллекцияМаршрутов.Добавить("default", "{controller=command}/{action=state}");

КонецПроцедуры // ОпределениеМаршрутов()