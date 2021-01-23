import Foundation

final class Services {
  let persistenceService: PersistenceService

  let yearsService = YearsService()
  let bundleService = BundleService()
  let playbackService = PlaybackService()
  let favoritesService = FavoritesService()
  let acknowledgementsService = AcknowledgementsService()

  private(set) lazy var infoService = InfoService(bundleService: bundleService)
  private(set) lazy var updateService = UpdateService(networkService: networkService)
  private(set) lazy var buildingsService = BuildingsService(bundleService: bundleService)
  private(set) lazy var tracksService = TracksService(favoritesService: favoritesService, persistenceService: persistenceService)

  private(set) lazy var networkService: NetworkService = {
    let session = URLSession.shared
    session.configuration.timeoutIntervalForRequest = 30
    session.configuration.timeoutIntervalForResource = 30
    return NetworkService(session: session)
  }()
  
  #if DEBUG
  private(set) lazy var debugService = DebugService()
  private(set) lazy var testsService = TestsService(persistenceService: persistenceService, favoritesService: favoritesService, debugService: debugService)
  #endif

  private(set) lazy var noticesService: NoticesService? = {
    var noticesService: NoticesService? = NoticesService(currentYear: yearsService.current)
    #if DEBUG
    if !testsService.shouldDiplayNotices {
      noticesService = nil
    }
    #endif
    return noticesService
  }()

  private(set) lazy var scheduleService: ScheduleService? = {
    var scheduleService: ScheduleService? = ScheduleService(fosdemYear: yearsService.current, networkService: networkService, persistenceService: persistenceService)
    #if DEBUG
    if !testsService.shouldUpdateSchedule {
      scheduleService = nil
    }
    #endif
    return scheduleService
  }()

  private(set) lazy var liveService: LiveService = {
    var liveService = LiveService()
    #if DEBUG
    if let timeInterval = testsService.liveTimerInterval {
      liveService = LiveService(timeInterval: timeInterval)
    }
    #endif
    return liveService
  }()

  init() throws {
    let launchService = LaunchService(fosdemYear: yearsService.current)
    try launchService.detectStatus()

    let preloadService = try PreloadService()
    // Remove the database after each update as the new database might contain
    // updates even if the year did not change.
    if launchService.didLaunchAfterUpdate {
      try preloadService.removeDatabase()
    }
    try preloadService.preloadDatabaseIfNeeded()

    persistenceService = try PersistenceService(path: preloadService.databasePath, migrations: .allMigrations)

    if launchService.didLaunchAfterFosdemYearChange {
      favoritesService.removeAllTracksAndEvents()
    }

    #if DEBUG
    testsService.configureEnvironment()
    #endif
  }
}
