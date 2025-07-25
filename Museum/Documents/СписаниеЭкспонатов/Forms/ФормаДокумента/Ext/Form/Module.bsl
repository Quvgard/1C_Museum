﻿
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ЭтоАдресВременногоХранилища(АдресВХранилище) Тогда		
		ТекущийОбъект.Файл = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(АдресВХранилище));
	КонецЕсли;
	
	История = РегистрыСведений.ИсторияСписания.СоздатьНаборЗаписей();        
	НачатьТранзакцию();
	Для Каждого Актив Из ТекущийОбъект.Экспонаты Цикл
		Экспонаты = Актив.Наименование.ПолучитьОбъект();
		Экспонаты.Статус = Перечисления.СтатусыЭкспонатов.Списано;
		Экспонаты.Записать();   
		
		История.Прочитать();
		ЗаписьИстории = История.Добавить();
		ЗаписьИстории.Период = Объект.Дата;
		ЗаписьИстории.Экспонат = Экспонаты.Ссылка;
		ЗаписьИстории.Идентификатор = Экспонаты.Код; 
		//ЗаписьИстории.Местоположение = Экспонаты.Местоположение;
		ЗаписьИстории.ОтветственноеЛицо = Экспонаты.ОтветственноеЛицо;  
		ЗаписьИстории.Статус = Экспонаты.Статус; 
		ЗаписьИстории.Основание = ТекущийОбъект.Основание;  
		История.Записать();
	КонецЦикла;             
	ЗафиксироватьТранзакцию();
КонецПроцедуры

&НаКлиенте
Процедура ЭкспонатыНаименованиеПриИзменении(Элемент)
	СтрокаТабличнойЧасти = Элементы.Экспонаты.ТекущиеДанные;
	СтрокаТабличнойЧасти.Идентификатор = ПолучитьИдентификаторТК(СтрокаТабличнойЧасти.Наименование);
КонецПроцедуры

Функция ПолучитьИдентификаторТК(Ссылка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Экспонаты.Код КАК Код
	|ИЗ
	|	Справочник.Экспонаты КАК Экспонаты
	|ГДЕ
	|	Экспонаты.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Код;
	КонецЦикла;
КонецФункции

//Файлы
&НаКлиенте
Процедура Загрузить(Команда)
	Диалог = новый ПараметрыДиалогаПомещенияФайлов("Выберите файл для загрузки");
	
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияДиалога", ЭтаФорма);
	НачатьПомещениеФайлаНаСервер(Оповещение,,,, Диалог, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияДиалога(ОписаниеФайла, ДопПараметры) Экспорт
	Попытка
	Если ОписаниеФайла.ПомещениеФайлаОтменено Тогда
		Возврат;
	КонецЕсли; 
	
	АдресВХранилище = ОписаниеФайла.Адрес;
	Объект.ИмяФайла = ОписаниеФайла.СсылкаНаФайл.Файл.Имя;
	
	Модифицированность = Истина;
	Исключение        
	    Предупреждение("Форма выбора файла была закрыта. Файл не выбран.");
	КонецПопытки;
КонецПроцедуры 

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ЭтоАдресВременногоХранилища(АдресВХранилище) Тогда
		УдалитьИзВременногоХранилища(АдресВХранилище);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Скачать(Команда)
	Попытка
		СсылкаНаФайлВИБ = ПолучитьНавигационнуюСсылку(Объект.Ссылка, "Файл");
		ПолучитьФайл(СсылкаНаФайлВИБ,Объект.ИмяФайла);
	Исключение
		Предупреждение("Перед тем как скачивать файл, его нужно загрузить! Если же вы попытались открыть или скачать только что загруженый файл, то его перед этим нужно сохранить, нажав кнопку 'Провести и закрыть'.");
	КонецПопытки;
КонецПроцедуры
