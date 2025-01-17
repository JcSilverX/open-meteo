/// On demand calculated variables
enum BomVariableDerived: String, CaseIterable, GenericVariableMixable {
    case apparent_temperature
    case relativehumidity_2m
    case dewpoint_2m
    case dew_point_2m
    case windspeed_10m
    case windspeed_40m
    case windspeed_80m
    case windspeed_120m
    case winddirection_10m
    case winddirection_40m
    case winddirection_80m
    case winddirection_120m

    case direct_normal_irradiance
    case direct_normal_irradiance_instant
    case direct_radiation_instant
    case diffuse_radiation_instant
    case diffuse_radiation
    case shortwave_radiation_instant
    case global_tilted_irradiance
    case global_tilted_irradiance_instant
    
    case et0_fao_evapotranspiration
    case vapour_pressure_deficit
    case vapor_pressure_deficit
    case surface_pressure
    case terrestrial_radiation
    case terrestrial_radiation_instant
    case weathercode
    case is_day
    case rain
    case snowfall
    case wet_bulb_temperature_2m
    case cloudcover
    case cloudcover_low
    case cloudcover_mid
    case cloudcover_high
    case windgusts_10m
    case sunshine_duration
    
    case soil_temperature_10_to_45cm
    case soil_temperature_40_to_100cm
    case soil_temperature_100_to_200cm
    
    case soil_moisture_10_to_40cm
    case soil_moisture_40_to_100cm
    case soil_moisture_100_to_200cm
    
    var requiresOffsetCorrectionForMixing: Bool {
        return false
    }
}

typealias BomVariableCombined = VariableOrDerived<VariableAndMemberAndControl<BomVariable>, VariableAndMemberAndControl<BomVariableDerived>>

struct BomReader: GenericReaderDerived, GenericReaderProtocol {
    typealias Domain = BomDomain
    
    typealias Variable = VariableAndMemberAndControl<BomVariable>
    
    typealias Derived = VariableAndMemberAndControl<BomVariableDerived>
    
    typealias MixingVar = BomVariableCombined
    
    let reader: GenericReaderCached<BomDomain, VariableAndMemberAndControl<BomVariable>>
    
    let options: GenericReaderOptions
    
    public init?(domain: Domain, lat: Float, lon: Float, elevation: Float, mode: GridSelectionMode, options: GenericReaderOptions) throws {
        guard let reader = try GenericReader<Domain, Variable>(domain: domain, lat: lat, lon: lon, elevation: elevation, mode: mode) else {
            return nil
        }
        self.reader = GenericReaderCached(reader: reader)
        self.options = options
    }
    
    func get(raw: VariableAndMemberAndControl<BomVariable>, time: TimerangeDt) throws -> DataAndUnit {
        return try reader.get(variable: raw, time: time)
    }
    
    func prefetchData(raw: VariableAndMemberAndControl<BomVariable>, time: TimerangeDt) throws {
        try reader.prefetchData(variable: raw, time: time)
    }
    
    func get(raw: BomVariable, member: Int, time: TimerangeDt) throws -> DataAndUnit {
        return try reader.get(variable: .init(raw, member), time: time)
    }
    
    func prefetchData(raw: BomVariable, member: Int, time: TimerangeDt) throws {
        try reader.prefetchData(variable: .init(raw, member), time: time)
    }
    
    func prefetchData(derived: VariableAndMemberAndControl<BomVariableDerived>, time: TimerangeDt) throws {
        let member = derived.member
        switch derived.variable {
        case .apparent_temperature:
            try prefetchData(raw: .temperature_2m, member: member, time: time)
            try prefetchData(raw: .wind_speed_10m, member: member, time: time)
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
            try prefetchData(raw: .shortwave_radiation, member: member, time: time)
        case .relativehumidity_2m:
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
        case .windspeed_10m:
            try prefetchData(raw: .wind_speed_10m, member: member, time: time)
        case  .windspeed_40m:
            try prefetchData(raw: .wind_speed_40m, member: member, time: time)
        case  .windspeed_80m:
            try prefetchData(raw: .wind_speed_80m, member: member, time: time)
        case  .windspeed_120m:
            try prefetchData(raw: .wind_speed_120m, member: member, time: time)
        case .winddirection_10m:
            try prefetchData(raw: .wind_direction_10m, member: member, time: time)
        case  .winddirection_40m:
            try prefetchData(raw: .wind_direction_40m, member: member, time: time)
        case  .winddirection_80m:
            try prefetchData(raw: .wind_direction_80m, member: member, time: time)
        case  .winddirection_120m:
            try prefetchData(raw: .wind_direction_120m, member: member, time: time)
        case .vapor_pressure_deficit, .vapour_pressure_deficit:
            try prefetchData(raw: .temperature_2m, member: member, time: time)
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
        case .et0_fao_evapotranspiration:
            try prefetchData(raw: .shortwave_radiation, member: member, time: time)
            try prefetchData(raw: .temperature_2m, member: member, time: time)
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
            try prefetchData(raw: .wind_speed_10m, member: member, time: time)
        case .surface_pressure:
            try prefetchData(raw: .pressure_msl, member: member, time: time)
            try prefetchData(raw: .temperature_2m, member: member, time: time)
        case .terrestrial_radiation, .terrestrial_radiation_instant:
            break
        case .dew_point_2m, .dewpoint_2m:
            try prefetchData(raw: .temperature_2m, member: member, time: time)
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
        case .direct_normal_irradiance, .direct_normal_irradiance_instant:
            try prefetchData(raw: .direct_radiation, member: member, time: time)
        case .shortwave_radiation_instant:
            try prefetchData(raw: .shortwave_radiation, member: member, time: time)
        case .global_tilted_irradiance, .global_tilted_irradiance_instant:
            fallthrough
        case .diffuse_radiation, .diffuse_radiation_instant:
            try prefetchData(raw: .shortwave_radiation, member: member, time: time)
            try prefetchData(raw: .direct_radiation, member: member, time: time)
        case .weathercode:
            try prefetchData(raw: .weather_code, member: member, time: time)
        case .is_day:
            break
        case .wet_bulb_temperature_2m:
            try prefetchData(raw: .temperature_2m, member: member, time: time)
            try prefetchData(raw: .relative_humidity_2m, member: member, time: time)
        case .cloudcover:
            try prefetchData(raw: .cloud_cover, member: member, time: time)
        case .cloudcover_low:
            try prefetchData(raw: .cloud_cover_low, member: member, time: time)
        case .cloudcover_mid:
            try prefetchData(raw: .cloud_cover_mid, member: member, time: time)
        case .cloudcover_high:
            try prefetchData(raw: .cloud_cover_high, member: member, time: time)
        case .windgusts_10m:
            try prefetchData(raw: .wind_gusts_10m, member: member, time: time)
        case .sunshine_duration:
            try prefetchData(raw: .direct_radiation, member: member, time: time)
        case .rain:
            try prefetchData(raw: .precipitation, member: member, time: time)
            try prefetchData(raw: .showers, member: member, time: time)
            try prefetchData(raw: .snowfall_water_equivalent, member: member, time: time)
        case .direct_radiation_instant:
            try prefetchData(raw: .direct_radiation, member: member, time: time)
        case .snowfall:
            try prefetchData(raw: .snowfall_water_equivalent, member: member, time: time)
        case .soil_temperature_10_to_45cm:
            try prefetchData(raw: .soil_temperature_10_to_35cm, member: member, time: time)
        case .soil_temperature_40_to_100cm:
            try prefetchData(raw: .soil_temperature_35_to_100cm, member: member, time: time)
        case .soil_temperature_100_to_200cm:
            try prefetchData(raw: .soil_temperature_100_to_300cm, member: member, time: time)
        case .soil_moisture_10_to_40cm:
            try prefetchData(raw: .soil_moisture_10_to_35cm, member: member, time: time)
        case .soil_moisture_40_to_100cm:
            try prefetchData(raw: .soil_moisture_35_to_100cm, member: member, time: time)
        case .soil_moisture_100_to_200cm:
            try prefetchData(raw: .soil_moisture_100_to_300cm, member: member, time: time)
        }
    }
    
    func get(derived: VariableAndMemberAndControl<BomVariableDerived>, time: TimerangeDt) throws -> DataAndUnit {
        let member = derived.member
        switch derived.variable {
        case .windspeed_10m:
            return try get(raw: .wind_speed_10m, member: member, time: time)
        case .windspeed_40m:
            return try get(raw: .wind_speed_40m, member: member, time: time)
        case .windspeed_80m:
            return try get(raw: .wind_speed_80m, member: member, time: time)
        case .windspeed_120m:
            return try get(raw: .wind_speed_120m, member: member, time: time)
        case .winddirection_10m:
            return try get(raw: .wind_direction_10m, member: member, time: time)
        case .winddirection_40m:
            return try get(raw: .wind_direction_40m, member: member, time: time)
        case .winddirection_80m:
            return try get(raw: .wind_direction_80m, member: member, time: time)
        case .winddirection_120m:
            return try get(raw: .wind_direction_120m, member: member, time: time)
        case .apparent_temperature:
            let windspeed = try get(raw: .wind_speed_10m, member: member, time: time).data
            let temperature = try get(raw: .temperature_2m, member: member, time: time).data
            let relhum = try get(raw: .relative_humidity_2m, member: member, time: time).data
            let radiation = try get(raw: .shortwave_radiation, member: member, time: time).data
            return DataAndUnit(Meteorology.apparentTemperature(temperature_2m: temperature, relativehumidity_2m: relhum, windspeed_10m: windspeed, shortware_radiation: radiation), .celsius)
        case .vapor_pressure_deficit, .vapour_pressure_deficit:
            let temperature = try get(raw: .temperature_2m, member: member, time: time).data
            let rh = try get(raw: .relative_humidity_2m, member: member, time: time).data
            let dewpoint = zip(temperature,rh).map(Meteorology.dewpoint)
            return DataAndUnit(zip(temperature,dewpoint).map(Meteorology.vaporPressureDeficit), .kilopascal)
        case .et0_fao_evapotranspiration:
            let exrad = Zensun.extraTerrestrialRadiationBackwards(latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            let swrad = try get(raw: .shortwave_radiation, member: member, time: time).data
            let temperature = try get(raw: .temperature_2m, member: member, time: time).data
            let windspeed = try get(raw: .wind_speed_10m, member: member, time: time).data
            let rh = try get(raw: .relative_humidity_2m, member: member, time: time).data
            let dewpoint = zip(temperature,rh).map(Meteorology.dewpoint)
            let et0 = swrad.indices.map { i in
                return Meteorology.et0Evapotranspiration(temperature2mCelsius: temperature[i], windspeed10mMeterPerSecond: windspeed[i], dewpointCelsius: dewpoint[i], shortwaveRadiationWatts: swrad[i], elevation: reader.targetElevation, extraTerrestrialRadiation: exrad[i], dtSeconds: 3600)
            }
            return DataAndUnit(et0, .millimetre)
        case .relativehumidity_2m:
            return try get(raw: .relative_humidity_2m, member: member, time: time)
        case .surface_pressure:
            let temperature = try get(raw: .temperature_2m, member: member, time: time).data
            let pressure = try get(raw: .pressure_msl, member: member, time: time)
            return DataAndUnit(Meteorology.surfacePressure(temperature: temperature, pressure: pressure.data, elevation: reader.targetElevation), pressure.unit)
        case .terrestrial_radiation:
            /// Use center averaged
            let solar = Zensun.extraTerrestrialRadiationBackwards(latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            return DataAndUnit(solar, .wattPerSquareMetre)
        case .terrestrial_radiation_instant:
            /// Use center averaged
            let solar = Zensun.extraTerrestrialRadiationInstant(latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            return DataAndUnit(solar, .wattPerSquareMetre)
        case .dewpoint_2m, .dew_point_2m:
            let temperature = try get(raw: .temperature_2m, member: member, time: time)
            let rh = try get(raw: .relative_humidity_2m, member: member, time: time)
            return DataAndUnit(zip(temperature.data, rh.data).map(Meteorology.dewpoint), temperature.unit)
        case .shortwave_radiation_instant:
            let sw = try get(raw: .shortwave_radiation, member: member, time: time)
            let factor = Zensun.backwardsAveragedToInstantFactor(time: time, latitude: reader.modelLat, longitude: reader.modelLon)
            return DataAndUnit(zip(sw.data, factor).map(*), sw.unit)
        case .direct_normal_irradiance:
            let dhi = try get(raw: .direct_radiation, member: member, time: time).data
            let dni = Zensun.calculateBackwardsDNI(directRadiation: dhi, latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            return DataAndUnit(dni, .wattPerSquareMetre)
        case .direct_normal_irradiance_instant:
            let direct = try get(derived: .init(.direct_radiation_instant, member), time: time)
            let dni = Zensun.calculateInstantDNI(directRadiation: direct.data, latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            return DataAndUnit(dni, direct.unit)
        case .diffuse_radiation:
            let swrad = try get(raw: .shortwave_radiation, member: member, time: time)
            let dhi = try get(raw: .direct_radiation, member: member, time: time)
            return DataAndUnit(zip(swrad.data, dhi.data).map(-), swrad.unit)
        case .direct_radiation_instant:
            let direct = try get(raw: .direct_radiation, member: member, time: time)
            let factor = Zensun.backwardsAveragedToInstantFactor(time: time, latitude: reader.modelLat, longitude: reader.modelLon)
            return DataAndUnit(zip(direct.data, factor).map(*), direct.unit)
        case .diffuse_radiation_instant:
            let diff = try get(derived: .init(.diffuse_radiation, member), time: time)
            let factor = Zensun.backwardsAveragedToInstantFactor(time: time, latitude: reader.modelLat, longitude: reader.modelLon)
            return DataAndUnit(zip(diff.data, factor).map(*), diff.unit)
        case .weathercode:
            return try get(raw: .weather_code, member: member, time: time)
        case .is_day:
            return DataAndUnit(Zensun.calculateIsDay(timeRange: time, lat: reader.modelLat, lon: reader.modelLon), .dimensionlessInteger)
        case .wet_bulb_temperature_2m:
            let temperature = try get(raw: .temperature_2m, member: member, time: time)
            let rh = try get(raw: .relative_humidity_2m, member: member, time: time)
            return DataAndUnit(zip(temperature.data, rh.data).map(Meteorology.wetBulbTemperature), temperature.unit)
        case .cloudcover:
            return try get(raw: .cloud_cover, member: member, time: time)
        case .cloudcover_low:
            return try get(raw: .cloud_cover_low, member: member, time: time)
        case .cloudcover_mid:
            return try get(raw: .cloud_cover_mid, member: member, time: time)
        case .cloudcover_high:
            return try get(raw: .cloud_cover_high, member: member, time: time)
        case .windgusts_10m:
            return try get(raw: .wind_gusts_10m, member: member, time: time)
        case .sunshine_duration:
            let directRadiation = try get(raw: .direct_radiation, member: member, time: time)
            let duration = Zensun.calculateBackwardsSunshineDuration(directRadiation: directRadiation.data, latitude: reader.modelLat, longitude: reader.modelLon, timerange: time)
            return DataAndUnit(duration, .seconds)
        case .rain:
            let precipitation = try get(raw: .precipitation, member: member, time: time)
            let showers = try get(raw: .showers, member: member, time: time)
            let snoweq = try get(raw: .snowfall_water_equivalent, member: member, time: time)
            return DataAndUnit(zip(precipitation.data, zip(snoweq.data, showers.data)).map({max($0 - $1.0 - $1.1, 0)}), precipitation.unit)
        case .snowfall:
            let snoweq = try get(raw: .snowfall_water_equivalent, member: member, time: time)
            return DataAndUnit(snoweq.data.map{$0*0.7}, .centimetre)
        case .soil_temperature_10_to_45cm:
            return try get(raw: .soil_temperature_10_to_35cm, member: member, time: time)
        case .soil_temperature_40_to_100cm:
            return try get(raw: .soil_temperature_35_to_100cm, member: member, time: time)
        case .soil_temperature_100_to_200cm:
            return try get(raw: .soil_temperature_100_to_300cm, member: member, time: time)
        case .soil_moisture_10_to_40cm:
            return try get(raw: .soil_moisture_10_to_35cm, member: member, time: time)
        case .soil_moisture_40_to_100cm:
            return try get(raw: .soil_moisture_35_to_100cm, member: member, time: time)
        case .soil_moisture_100_to_200cm:
            return try get(raw: .soil_moisture_100_to_300cm, member: member, time: time)
        case .global_tilted_irradiance:
            let directRadiation = try get(raw: .direct_radiation, member: member, time: time).data
            let ghi = try get(raw: .shortwave_radiation, member: member, time: time).data
            let diffuseRadiation = zip(ghi, directRadiation).map(-)
            let gti = Zensun.calculateTiltedIrradiance(directRadiation: directRadiation, diffuseRadiation: diffuseRadiation, tilt: try options.getTilt(), azimuth: try options.getAzimuth(), latitude: reader.modelLat, longitude: reader.modelLon, timerange: time, convertBackwardsToInstant: false)
            return DataAndUnit(gti, .wattPerSquareMetre)
        case .global_tilted_irradiance_instant:
            let directRadiation = try get(raw: .direct_radiation, member: member, time: time).data
            let ghi = try get(raw: .shortwave_radiation, member: member, time: time).data
            let diffuseRadiation = zip(ghi, directRadiation).map(-)
            let gti = Zensun.calculateTiltedIrradiance(directRadiation: directRadiation, diffuseRadiation: diffuseRadiation, tilt: try options.getTilt(), azimuth: try options.getAzimuth(), latitude: reader.modelLat, longitude: reader.modelLon, timerange: time, convertBackwardsToInstant: true)
            return DataAndUnit(gti, .wattPerSquareMetre)
        }
    }
}
