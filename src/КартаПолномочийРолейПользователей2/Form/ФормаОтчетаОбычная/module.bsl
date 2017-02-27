﻿
////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД

Процедура ДействияФормыСформироватьОтчет(Кнопка)
	
	СтруктураНастроек = ПолучитьСтруктуруНастроекФормыДляЗаписи();
	МассивИменРолей = ПолучитьМассивИменРолейПоНастройкам(СтруктураНастроек);
	ТабДок = ВывестиОтчетВТабличныйДокумент(МассивИменРолей, СтруктураНастроек);
	
	ПолеОтчета = ЭлементыФормы.ПолеОтчета;
	ПолеОтчета.Очистить();
	ПолеОтчета.Вывести(ТабДок);
	
КонецПроцедуры

Процедура ДействияФормыкнСохранить(Кнопка)
	
	Перем ПутьКФайлу;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДиалогВыбораФайла.ПолноеИмяФайла = ПутьКФайлу;
	ДиалогВыбораФайла.МножественныйВыбор = Ложь;
	ДиалогВыбораФайла.Заголовок = НСтр("ru = 'Выбор файла выгрузки'");
	ДиалогВыбораФайла.Фильтр = "Файлы выгрузки (*.xml)|*.xml|Все файлы (*.*)|*.*";
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		ПутьКФайлу = ДиалогВыбораФайла.ПолноеИмяФайла;
	КонецЕсли;
	
	СтруктураНастроек = ПолучитьСтруктуруНастроекФормыДляЗаписи();
	МассивИменРолей = ПолучитьМассивИменРолейПоНастройкам(СтруктураНастроек);
	
	СтруктураНастроек.Вставить("ПутьКФайлу", ПутьКФайлу);
	
	ВывестиОтчетВXML(МассивИменРолей, СтруктураНастроек);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

Функция ПолучитьМассивИменРолейПоНастройкам(СтруктураНастроек)
	
	МассивИменРолей = Новый Массив;
	
	Если ТипПолномочия = "Роль" Тогда
		
		Если НЕ ЗначениеЗаполнено(СтруктураНастроек.РольРеквизит) Тогда
			Предупреждение(НСтр("ru = 'Не выбрана роль!'"), 60, "Ошибка!");
			Возврат Неопределено;
		КонецЕсли;
		
		МассивИменРолей.Добавить(СтруктураНастроек.РольРеквизит);
		
	ИначеЕсли ТипПолномочия = "Роли" Тогда
		
		Для Каждого ЭлементСписка Из СтруктураНастроек.СписокРолейРеквизит Цикл
			Если ЭлементСписка.Пометка Тогда
				МассивИменРолей.Добавить(ЭлементСписка.Значение);
			КонецЕсли;
		КонецЦикла;
		
		Если МассивИменРолей.Количество() = 0 Тогда
			Предупреждение(НСтр("ru = 'Не выбрано ни одной роли!'"), 60, "Ошибка!");
			Возврат Неопределено;
		КонецЕсли;
		
	ИначеЕсли ТипПолномочия = "Пользователь" Тогда
		
		Если НЕ ЗначениеЗаполнено(СтруктураНастроек.ПользовательИБ) Тогда
			Предупреждение(НСтр("ru = 'Не выбран пользователь!'"), 60, "Ошибка!");
			Возврат Неопределено;
		КонецЕсли;
		
		метаПользователь = ПолучитьПользователяИБПоИмени(СтруктураНастроек.ПользовательИБ);
		Для Каждого ТекРоль Из метаПользователь.Роли Цикл
			МассивИменРолей.Добавить(ТекРоль.Имя);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат МассивИменРолей;
	
КонецФункции

Функция ПолучитьСтруктуруНастроекФормыДляЗаписи()
	
	СтрПарам = Новый Структура();
	СтрПарам.Вставить("НеВыводитьОбъектБезПрав", НеВыводитьОбъектБезПрав);
	СтрПарам.Вставить("ПользовательИБ", ПользовательИБ);
	СтрПарам.Вставить("РольРеквизит", РольРеквизит);
	СтрПарам.Вставить("ТипПолномочия", ТипПолномочия);
	
	ТабРоли = Новый ТаблицаЗначений;
	ТабРоли.Колонки.Добавить("Значение");
	ТабРоли.Колонки.Добавить("Представление");
	ТабРоли.Колонки.Добавить("Пометка");
	Для Каждого ЭлементСписка Из СписокРолейРеквизит Цикл
		ЗаполнитьЗначенияСвойств(ТабРоли.Добавить(), ЭлементСписка);
	КонецЦикла;
	СтрПарам.Вставить("СписокРолейРеквизит", ТабРоли);
	
	Возврат СтрПарам;
	
КонецФункции

Процедура ОбновитьОтображениеГиперссылки()
	
	КолРолей = 0;
	СтрРоли = "";
	Для Каждого ЭлементСписка Из СписокРолейРеквизит Цикл
		Если ЭлементСписка.Пометка Тогда
			СтрРоли = СтрРоли + ", " + ЭлементСписка.Значение;
			КолРолей = КолРолей + 1;
		КонецЕсли;
	КонецЦикла;
	СтрРоли = Сред(СтрРоли,3);
	
	Если КолРолей > 0 Тогда
		ЭлементыФормы.ГиперрссылкаВыборРолей.Заголовок = "("+КолРолей+") "+?(СтрДлина(СтрРоли)>90, Лев(СтрРоли, 87)+"...", СтрРоли);
	Иначе
		ЭлементыФормы.ГиперрссылкаВыборРолей.Заголовок = НСтр("ru = 'Не выбрано ни одной роли'");
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриИзмененииТипаПолномочия()
	
	ЭлементыФормы.ПанельНастроек.ТекущаяСтраница = ЭлементыФормы.ПанельНастроек.Страницы[ТипПолномочия];
	
	ОбновитьОтображениеГиперссылки();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ И ЭЛЕМЕНТОВ ДИАЛОГА

Процедура ТипПолномочияПриИзменении(Элемент)
	
	ПриИзмененииТипаПолномочия();
	
КонецПроцедуры

Процедура ГиперрссылкаВыборРолейНажатие(Элемент)
	
	Если СписокРолейРеквизит.ОтметитьЭлементы(НСтр("ru = 'Выбор ролей для отчета'")) Тогда
		ОбновитьОтображениеГиперссылки();
	КонецЕсли
	
КонецПроцедуры

Процедура ПриОткрытии()
	
	СписокРолей = ПолучитьСписокРолей();
	СписокПользователей = ПолучитьСписокПользователейИБ();
	
	ЭлементыФормы.РольРеквизит.СписокВыбора.Очистить();
	СписокРолейРеквизит.Очистить();
	Для Каждого ЭлементСписка Из СписокРолей Цикл
		ЭлементыФормы.РольРеквизит.СписокВыбора.Добавить(ЭлементСписка.Значение, ЭлементСписка.Представление);
		СписокРолейРеквизит.Добавить(ЭлементСписка.Значение, ЭлементСписка.Представление);
	КонецЦикла;
	
	ЭлементыФормы.ПользовательИБ.СписокВыбора.Очистить();
	Для Каждого ЭлементСписка Из СписокПользователей Цикл
		ЭлементыФормы.ПользовательИБ.СписокВыбора.Добавить(ЭлементСписка.Значение, ЭлементСписка.Представление);
	КонецЦикла;
	
	ТипПолномочия = "Роль";
	ПриИзмененииТипаПолномочия();
	ЭтаФорма.Заголовок = НСтр("ru = 'Карта полномочий ролей и пользователей ('") + Версия() + ")";
	
КонецПроцедуры

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	ПроверитьВерсиюПлатформыПриЗапуске(Отказ);
	
КонецПроцедуры
