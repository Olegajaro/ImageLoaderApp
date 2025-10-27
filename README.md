# ImageLoaderApp

Проект для тестового задания — кастомная реализация коллекции изображений с кэшированием и анимациями, без использования IB (Storyboard, xib) и сторонних зависимостей.

## 📱 О проекте

Приложение отображает коллекцию из 6 изображений с возможностью:
- Асинхронной загрузки изображений (от 800×600 px)
- Двухуровневого кэширования (память + диск) для оффлайн работы
- Кастомных анимаций удаления ячеек со сдвигом
- Pull-to-refresh для полного сброса состояния
- Поддержки обеих ориентаций экрана

## 🛠 Технологии

- **Язык:** Swift
- **Минимальная версия iOS:** 16.0+
- **Архитектура:** MVP-like
- **UI:** Программная верстка (без Interface Builder/SwiftUI)
- **Кэширование:** `NSCache` + `FileManager`
- **Сеть:** `URLSession`
- **Основные компоненты:** `UINavigationController`, `UICollectionView`

## 🏗 Структура проекта

ImageLoaderApp/
├── App/
│ ├── AppDelegate
│ └── SceneDelegate
├── Controllers/
│ ├── ImagesCollectionViewController // UI-логика экрана
│ └── ImagesPresenter // связывает данные с отображением
├── Managers/
│ ├── ImageLoader // основной фасад загрузки изображений
│ ├── ImageDownloader // асинхронная загрузка через URLSession
│ ├── MemoryCache // кеш в оперативной памяти (NSCache)
│ ├── DiskCache // кеш на диске (FileManager)
│ └── ImageURLProvider // список URL для изображений
├── Views/
│ └── ImagesCollectionView // конфигурация и лэйаут коллекции
└── UIComponents/
└── ImageCollectionViewCell // кастомная ячейка
