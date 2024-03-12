#' Make a duration human readable
#'
#' @param time_in_secs A number of length one.
#'
#' @return A character of length one containing the human readable duration.
#' @examples
#' human_readable_duration(time_in_secs = 11 * 24 * 3600 + 1 * 3600 + 1 * 60 + 1.001001001)
#'
#' @export
human_readable_duration <- function(
    time_in_secs = c(
      0 * 24 * 3600 + 1 * 3600 + 1 * 60 + 1.001001001,
      0 * 24 * 3600 + 1 * 3600 + 0 * 60 + 1.001001001
    )
) {
  # store current count of digits for diplaying doubles
  digits <- getOption('digits')
  # set digits to 20
  options(digits = 20)

  ###
  # deconstruct time_in_secs to higher units
  days <- time_in_secs %/% (24 * 3600)
  time_in_secs <- time_in_secs - days * (24 * 3600)

  hours <- time_in_secs %/% 3600
  time_in_secs <- time_in_secs - hours * 3600

  mins  <- time_in_secs %/% 60
  time_in_secs <- time_in_secs - mins * 60

  secs  <- floor(time_in_secs)
  time_in_secs <- time_in_secs - secs

  time_in_secs <- time_in_secs * 1e3

  msecs  <- floor(time_in_secs)
  time_in_secs <- time_in_secs - msecs

  time_in_secs <- time_in_secs * 1e3

  musecs  <- floor(time_in_secs)
  time_in_secs <- time_in_secs - musecs

  nsecs <- floor(1e3 * time_in_secs + .5)

  # fill table with those values
  time_dt <- data.table::data.table(
    days         = days,
    hours        = hours,
    mins         = mins,
    secs         = secs,
    msecs        = msecs,
    '\u00B5secs' = musecs,
    nsecs        = nsecs
  )
  #    days hours mins secs msecs µsecs nsecs
  # 1:    0     1    1    1     1     1     1
  # 2:    0     1    0    1     1     1     1

  # delete leading zeros in table
  time_dt <- data.table::as.data.table(t(apply(
    time_dt,
    1,
    function(row) {
      i <- 1
      while (i <= length(row) - 1 && (is.na(row[[i]]) || row[[i]] == '0')) {
        row[[i]] <- ''
        i <- i + 1
      }
      row
    }
  ))
  )
  #    days hours mins secs msecs µsecs nsecs
  # 1:          1    1    1     1     1     1
  # 2:          1    0    1     1     1     1

  # restore digits
  options(digits = digits)

  # Binding the variable .SD locally to the function, so the R CMD check has nothing to complain about
  .SD <- NULL
  # return data table without empty leading column
  #    hours mins secs msecs µsecs nsecs
  # 1:     1    1    1     1     1     1
  # 2:     1    0    1     1     1     1
  time_dt[, .SD, .SDcols = sapply(time_dt, function(x) any(x != ''))]
}

###
# STATE LEVEL CONSTANTS to mark state of a process in time table
STATE_LEVELS <- c('OK', 'ERROR', 'RUNNING', 'UNDEFINED')

#' Clock Class
#'
#' This class represents a clock with methods to manage and record time-related events.
#' This class is for logging nested processes with their run times and states. It
#' represents a clock that can be used to measure process times and maintain a
#' history of activities.
#'
#' @importFrom stringr str_pad
#' @export
#' @rdname Clock
Clock = setRefClass(
  Class = 'Clock',
  # only one data table as class variable
  fields = c(
    .history = 'data.table'
  ),
  methods = list(

    # Constructor for Clock class.
    #
    # Initializes the clock and creates an initial entry in the history table.
    # This method resets the clock to its initial state by reinitializing the .history table.
    #
    initialize = function() {
      # store digits for later restoring
      digits <- getOption('digits')
      # set digits to 20
      options(digits = 20)
      # get current time
      now_ <- Sys.time()
      # add init row with creation time
      .history <<- data.table::data.table(
        id       = '0',
        msg      = 'init',
        state    = factor('OK', levels = STATE_LEVELS),
        start    = now_,
        end      = now_,
        error    = ''
      )
      # restore digits
      options(digits = digits)
    },

    # Reset the clock to its initial state (more or less the same as the constructor initialize).
    #
    # This method resets the clock to its initial state by reinitializing the .history table.
    #
    # @return No return value.
    #
    reset = function() {
      # store digits for later restoring
      digits <- getOption('digits')
      # set digits to 20
      options(digits = 20)
      # get current time
      now_ <- Sys.time()
      # add init row with creation time
      .history <<- data.table::data.table(
        id       = '0',
        msg      = 'init',
        state    = factor('OK', levels = STATE_LEVELS),
        start    = now_,
        end      = now_,
        error    = ''
      )
      # restore digits
      options(digits = digits)
    },

    # Write the history table to disk.
    #
    # This method writes the .history table to disk, optionally hiding errors.
    #
    # @param filename_without_extension The filename (without extension) for writing the table.
    # @param sep The separator for the output file (default is '\t').
    # @param ext The file extension (default is 'tsv').
    # @param hide_errors If TRUE, the error column is removed from the table (default is TRUE).
    #
    # @return No return value.
    #
    write = function(filename_without_extension, sep = '\t', ext = 'tsv', hide_errors = TRUE) {
      # convert extensions as "*.csv" or ".csv" or "csv" to ".csv"
      ext <- paste0(".", gsub("(^\\*\\.)|(^\\.)", "", ext))
      # complete table and store locally in h
      h <- complete()
      # write time data table to disk
      # if flag hide_errors then remove error column in table
      utils::write.table(x = if (hide_errors) h[,-c('error')] else h, file = paste0(filename_without_extension, ext), sep = sep, row.names = FALSE)
    },

    # Measure process time for a specific task.
    #
    # This method measures the process time for a specific task, updates the .history table,
    # and returns the result or error of the task.
    #
    # @param message A message describing the task.
    # @param process The function representing the task to be measured.
    # @param verbose Level of verbosity (default is 0).
    #
    # @return No return value.
    #
    measure_process_time = function(message, process, verbose = 0) {
      # if message is a vector of length zero, set it to empty string
      if (length(message) < 1) {
        warning(paste0('message has length ', length(message), '. Should be one.'))
        message <- ""
      }
      # if message is a vector longer than 1, use only 1st element
      if (1 < length(message)) {
        warning(paste0('message has length ', length(message), '. Only the first element will be used.'))
        message <- message[[1]]
      }
      # store digits
      digits <- getOption('digits')
      # set digits to 20
      options(digits = 20)
      # get nesting level by counting the running processes
      level <- sum(.history$state == 'RUNNING')
      # calc id
      id <- if (level == 0) {# if no process is running
        # starts with numbers?
        regex <- '^[0-9]+$'
        # get latest row which id is starting with numbers
        row <- max(grep(regex, .history[,id]))
        # store id of that row
        cid <- .history[row, id]
        # return this id incremented and as a character
        as.character(as.numeric(cid) + 1)
      } else {#if processes are running
        row <- max(which(.history$state == 'RUNNING'))
        # get latest running process
        coid <- .history[row, id]
        # create regex for finding inner processes
        regex <- paste0('^', gsub('\\.', '\\\\.', coid), '\\.[0-9]+$')
        # find inner process by id
        inners <- grep(regex, .history[, id])
        # set ciid to -1 for no inner processes
        # set ciid to max(inners)
        ciid <- if (0 < length(inners)) max(inners) else -1

        if (ciid < 0) {# add new inner process
          paste0(coid, '.1')
        } else {# increment id for new inner process
          s <- as.numeric(base::strsplit(.history[ciid, id], '\\.')[[1]])
          s[length(s)] <- s[length(s)] + 1
          paste0(s, collapse = '.')
        }
      }
      # get current time
      now_ <- Sys.time()
      # create new row for current running process
      d <- data.frame(
        id       = id,
        msg      = message,
        state    = factor('RUNNING', levels = STATE_LEVELS),
        start    = now_,
        end      = as.POSIXct(NA),
        error    = ''
      )
      # add new row to history table
      .history <<- rbind.data.frame(.history, d)
      # if 0 < verbose print a message
      if (0 < verbose) cat(paste0('start    ', message, ': ', d$start, '\n'))
      # run process and store result in err
      err <- try(process, silent = TRUE)
      # get end time
      now_ <- Sys.time()
      # find row of current running process
      last_row <- max(which(.history$state == 'RUNNING'))
      # add end time, error and state to this row
      .history[last_row, 'end'] <<- now_
      .history[last_row, 'error'] <<- if (inherits(err, 'try-error')) err else ''
      .history[last_row, 'state'] <<- if (inherits(err, 'try-error')) 'ERROR' else 'OK'
      # if 0 < verbose print some messages
      if (0 < verbose) {
        cat(paste0('finish   ', message, ': ', .history[last_row, end], '\n'))
        cat(paste0('duration ', message, ': ', .history[last_row, end] - .history[last_row, start], 's\n'))
      }
      # restore digits
      options(digits = digits)
      # return result or error
      err
    },

    # Create a human-readable version of the history table.
    #
    # This method creates a human-readable version of the .history table.
    #
    # @return A data.table with human-readable information.
    #
    complete = function() {
      h <- data.table::copy(x = .history)
      h <- base::cbind(
        h[,c('msg', 'id', 'state')],
        h[, human_readable_duration(time_in_secs = as.double(difftime(end, start, 'secs')))],
        h[,c('start', 'end', 'error')]
      )
      h[,id := stringr::str_pad(string = id, width = max(nchar(id)), side = 'right', pad = ' ')]
      h[]
    },

    # Display the human-readable version of the history table.
    #
    # This method prints the human-readable version of the .history table.
    #
    # @return No return value.
    #
    show = function() {
      print(complete())
    }
  )
)

#' Create a Clock
#'
#' @return a Clock
#'
#' @examples
#' my_clock <- createClock()
#' my_clock$measure_process_time('Process A', {Sys.sleep(1)})
#' # show raw data
#' my_clock$complete()
#' # reset clock
#' my_clock$reset()
#' # show clock
#' my_clock$show() # the same as my_clock or print(my_clock)
#' ### save time measurements as tsv
#' # my_clock$write('my_clock')
#' ### save time measurements as csv
#' # my_clock$write(
#' #   filename_without_extension = 'my_clock',
#' #   sep = ',',
#' #   ext = 'csv',
#' #   hide_errors = FALSE
#' # )
#'
#' @export
createClock <- function() {
  methods::new(Class = 'Clock')
}
