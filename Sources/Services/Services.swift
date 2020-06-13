import Foundation

final class Services {
  let infoService: InfoService
  let liveService: LiveService
  let crashService: CrashService?
  let updateService: UpdateService
  let tracksService: TracksService
  let yearsService = YearsService()
  let networkService: NetworkService
  let bundleService = BundleService()
  let scheduleService: ScheduleService
  let buildingsService: BuildingsService
  let playbackService = PlaybackService()
  let favoritesService = FavoritesService()
  let persistenceService: PersistenceService
  let acknowledgementsService = AcknowledgementsService()

  #if DEBUG
  let testsService: TestsService
  let debugService = DebugService()
  #endif

  init() throws {
    let preloadService = try PreloadService()
    try preloadService.preloadDatabaseIfNeeded()

    let path = preloadService.databasePath
    persistenceService = try PersistenceService(path: path, migrations: .allMigrations)

    let session = URLSession.shared
    session.configuration.timeoutIntervalForRequest = 30
    session.configuration.timeoutIntervalForResource = 30
    networkService = NetworkService(session: session)

    #if DEBUG
    crashService = nil
    #else
    crashService = CrashService(networkService: networkService)
    #endif

    #if DEBUG
    testsService = TestsService(favoritesService: favoritesService, debugService: debugService)
    testsService.configureEnvironment()
    #endif

    #if DEBUG
    if let timeInterval = testsService.liveTimerInterval {
      liveService = LiveService(timeInterval: timeInterval)
    } else {
      liveService = LiveService()
    }
    #else
    liveService = LiveService()
    #endif

    updateService = UpdateService(networkService: networkService)
    tracksService = TracksService(favoritesService: favoritesService, persistenceService: persistenceService)
    scheduleService = ScheduleService(networkService: networkService, persistenceService: persistenceService)

    infoService = InfoService(bundleService: bundleService)
    buildingsService = BuildingsService(bundleService: bundleService)
  }
}
