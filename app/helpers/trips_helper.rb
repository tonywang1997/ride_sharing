module TripsHelper
  def find_trip trips, res
    trips.each do |t|
      if t.availability_id == -1
        # if driver accepts request by using accept ride button
        res << [t.request_id, "request", t.id]
      else
        # if driver confirms rider's request
        res << [t.availability_id, "availability", t.id]
      end
    end
    return res
  end

  def can_cancel_trip param_time
    if Time.now > param_time
      return false
    else
      if ((param_time - Time.now) / 1.hour).to_f > 24.0
          return true
      end
      return false
    end
  end

  def rate_user driver, rider, trip, rating
    driver.number_of_rating_given += 1
    rider.number_of_rating_received += 1
    rider.sum_of_rating_received += rating
    driver.sum_of_rating_given += rating
    driver.save
    rider.save
    trip.status = "completed"
    trip.save
  end
end
