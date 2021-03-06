massShift <-
function(sequence, label = "none", aa, shift){

  # Check inputs
  label <- tolower(label) # Renders case-insensitive input string.
  if(!(label %in% c("none", "silac_13c", "silac_13c15n", "15n"))){
    stop("Given label type unknown. Please use one of 'none', '15N', 'Silac_13C15N', or 'Silac_13C' (case-insensitive).")
  }
  if(label == "none" & ((!missing("aa") & missing("shift")) | (missing("aa") & !missing("shift")))){
    stop("Both 'aa' and 'shift' must be defined.")
  }
  if(!missing("aa") & !missing("shift")){
    if(length(shift) != 1 & length(shift) != length(aa)){
      stop("If 'aa' is given, 'shift' must be a vector of length 1 or of the same length as 'aa'.")
    }
  }

  # Predefined labels
  if (label == "silac_13c"){
    aa <- "KR"
    shift <- 6.020129
  } else if(label == "silac_13c15n"){
    aa <- c("K", "R")
    shift <- c(8.014199, 10.008269)
  }

  # Add mass shifts
  shiftTotal <- 0
  if(!missing(aa)){
    aa <- as.list(aa)
    aa <- lapply(aa, function(x) unlist(strsplit(x, "")))
    for (i in 1:length(aa)){
      for (j in 1:length(aa[[i]])){
        n <- stri_count(sequence, fixed = aa[[i]][j])
        if (length(shift) < length(aa)) {
          shiftTotal <- shiftTotal + n * shift
        } else {
          shiftTotal <- shiftTotal + n * shift[i]
        }
      }
    }
  }

  # Add mass shifts for 15N labelling
  if(label == "15n"){
    shiftTotal <- 0
    for (i in 1:nrow(massTable)){
      nN <- stri_count(sequence, fixed = massTable$oneLetter[i]) * massTable$AnzahlN[i]
      shiftTotal <- shiftTotal + nN * 0.997035 # 0.997035 ist der mass shift zwischen 14N zu 15N. Da der nat?rliche Anteil an 15N nur 0.4% ist, kann der gleiche Unterschied f?r die Monoisotopic Mass und  f?r die Average Mass benutzt werden.
    }
  }

  return(shiftTotal)
}
