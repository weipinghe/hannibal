# Copyright 2012 Sentric. See LICENSE for details.

class @MetricsSeries

  constructor: () ->
    @series = []
    @palette = new Rickshaw.Color.Palette( { scheme: [
      '#B1354A',
      '#B12BA0',
      '#68B15D',
      '#4E5FB1',
      '#B1A667',
      '#56AFB1', # not used
    ] } )

  populate: (metrics) ->
    metrics.each((metric) => @findOrCreateSeries(metric.getName()).populate(metric))

  findOrCreateSeries: (name) ->
    found = @findSeries(name)
    if(!found)
      found = new MetricSeries(name, @palette.color())
      @series.push(found)
    found

  findSeries: (name) -> _(@series).find((series) -> series.metricName == name)


class @MetricSeries

  constructor: (metricName, color) ->
    @metricName = metricName
    @color = color
    @max = -1;
    @min = 99999999;

  populate: (metric) ->
    @name = @getHumanReadableName()
    @unit = @getHumanReadableUnit()
    @metric = metric

    step = Math.round(metric.getStep() / 1000)
    values = metric.getValues()
    begin = Math.round(metric.getBegin() / 1000)
    end = Math.round(metric.getEnd() / 1000)
    pointIndex = -1
    pointValue = metric.getPrevValue()

    @min = metric.getMin()
    @max = metric.getMax()
    @mm = @max - @min
    if @mm == 0.0
      console.log ("min-max difference is 0, setting to 1.0")
      @mm = 1.0

    @data = _.range(begin, end + step, step).map((ts) =>
      if(pointIndex < values.length - 1 && ts > Math.round(values[pointIndex+1].ts / 1000))
        pointIndex = pointIndex + 1
        pointValue = values[pointIndex].v

      return {
        x: ts
        y: @normalize(pointValue)
      }
    );

  denormalize: (v) ->
    Math.round((v - 0.025) * @mm + @min)

  normalize: (v) ->
    (v - @min) / @mm + 0.025

  getHumanReadableName: ->
    switch @metricName
      when "storefiles" then "Storefiles"
      when "storefileSizeMB" then "Storefile Size"
      when "memstoreSizeMB" then "Memstore Size"
      when "compactions" then "Compactions"

  getHumanReadableUnit: ->
    switch @metricName
      when "storefiles" then ""
      when "storefileSizeMB" then "MB"
      when "memstoreSizeMB" then "MB"
      when "compactions" then ""
